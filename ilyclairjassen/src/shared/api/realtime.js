import { supabase } from './supabase.js';

/**
 * Shared Realtime Helper — subscribeWithFallback
 *
 * Creates a Supabase Realtime subscription for a table with:
 * - Automatic 30-second polling fallback on CHANNEL_ERROR / TIMED_OUT
 * - 3-attempt auto-reconnect (3-second delay between attempts) on CLOSED
 * - Cleanup handle via the returned unsubscribe() function
 *
 * @param {string}   channelName  Unique channel identifier (e.g., 'messages-realtime')
 * @param {string}   table        Supabase table name to subscribe to
 * @param {Function} onInsert     Called with (newRow) when a row is INSERTed
 * @param {Function} fetchAll     Called every 30s as polling fallback; also called after reconnect
 * @returns {{ unsubscribe: Function }} Cleanup handle — call to stop subscription + polling
 */
export function subscribeWithFallback(channelName, table, onInsert, fetchAll) {
  let pollingTimer = null;
  let reconnectAttempts = 0;
  const MAX_RECONNECT = 3;
  const RECONNECT_DELAY_MS = 3000;
  const POLL_INTERVAL_MS = 30000;

  if (!supabase) {
    console.warn(`[Realtime] Supabase not initialized — falling back to polling for ${table}`);
    pollingTimer = setInterval(fetchAll, POLL_INTERVAL_MS);
    return { unsubscribe: () => clearInterval(pollingTimer) };
  }

  let channel = null;

  function startPolling() {
    if (pollingTimer) return; // already polling
    console.warn(`[Realtime] Starting 30s polling fallback for ${table}`);
    pollingTimer = setInterval(fetchAll, POLL_INTERVAL_MS);
  }

  function stopPolling() {
    if (pollingTimer) {
      clearInterval(pollingTimer);
      pollingTimer = null;
    }
  }

  function subscribe() {
    channel = supabase
      .channel(channelName)
      .on(
        'postgres_changes',
        { event: 'INSERT', schema: 'public', table },
        (payload) => {
          if (payload?.new) onInsert(payload.new);
        }
      )
      .subscribe((status) => {
        console.log(`[Realtime] Channel "${channelName}" status: ${status}`);

        if (status === 'SUBSCRIBED') {
          // Realtime is working — stop polling and fetch any missed rows
          reconnectAttempts = 0;
          stopPolling();
          fetchAll();
        } else if (status === 'CHANNEL_ERROR' || status === 'TIMED_OUT') {
          // Subscription failed — start polling as a fallback
          startPolling();
        } else if (status === 'CLOSED') {
          // Connection closed — attempt to reconnect up to MAX_RECONNECT times
          if (reconnectAttempts < MAX_RECONNECT) {
            reconnectAttempts++;
            console.warn(
              `[Realtime] Channel closed — reconnect attempt ${reconnectAttempts}/${MAX_RECONNECT} in ${RECONNECT_DELAY_MS}ms`
            );
            setTimeout(() => {
              supabase.removeChannel(channel);
              subscribe(); // re-enter the subscription flow
            }, RECONNECT_DELAY_MS);
          } else {
            console.warn(
              `[Realtime] Max reconnect attempts reached for "${channelName}" — switching to polling`
            );
            startPolling();
          }
        }
      });
  }

  subscribe();

  return {
    unsubscribe() {
      stopPolling();
      if (channel && supabase) {
        supabase.removeChannel(channel);
        channel = null;
      }
    }
  };
}
