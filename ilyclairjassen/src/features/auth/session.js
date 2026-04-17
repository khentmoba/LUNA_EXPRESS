/**
 * Session State Management
 * Handles saving and loading the user session from sessionStorage.
 */

export const Session = {
  user: null,

  load() {
    try {
      this.user = JSON.parse(sessionStorage.getItem('sanctuary_user') || 'null');
    } catch (e) {
      console.error('[Session] Error loading session:', e);
      this.user = null;
    }
    return this.user;
  },

  save(user) {
    this.user = user;
    try {
      sessionStorage.setItem('sanctuary_user', JSON.stringify(user));
    } catch (e) {
      console.error('[Session] Error saving session:', e);
    }
  },

  clear() {
    this.user = null;
    try {
      sessionStorage.removeItem('sanctuary_user');
    } catch (e) {
      console.error('[Session] Error clearing session:', e);
    }
  },

  isAuthenticated() {
    return !!this.load();
  }
};
