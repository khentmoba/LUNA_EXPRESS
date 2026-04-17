import './gatekeeper.css';
import { Session } from './session';

/**
 * Gatekeeper Feature
 * Fullscreen portal blocking access until correct birthday is entered.
 */

const BIRTHDAYS = { 
  khent: '2006-10-26', 
  clair: '2006-02-21' 
};

let selectedUser = null;
let portal = null;

/**
 * Initializes the Gatekeeper.
 * @param {Function} onUnlock - Callback fired when authentication succeeds.
 */
export function initGatekeeper(onUnlock) {
  // If already authenticated, just trigger the callback
  if (Session.load()) {
    if (onUnlock) onUnlock(Session.user);
    return;
  }

  renderPortal(onUnlock);
}

function renderPortal(onUnlock) {
  const viewport = document.getElementById('viewport');
  if (viewport) {
    viewport.style.filter = 'blur(12px) brightness(0.3)';
    viewport.style.pointerEvents = 'none';
  }

  portal = document.createElement('div');
  portal.id = 'gatekeeper';
  
  // Add floating particles
  for (let i = 0; i < 18; i++) {
    const dot = document.createElement('div');
    const sz = 2 + Math.random() * 4;
    dot.style.cssText = `
      position:absolute;
      border-radius:50%;
      background:rgba(${180 + Math.random() * 75 | 0},${80 + Math.random() * 60 | 0},${200 + Math.random() * 55 | 0},0.7);
      width:${sz}px;
      height:${sz}px;
      left:${Math.random() * 100}%;
      bottom:${Math.random() * 30}%;
      animation:gkFloat ${6 + Math.random() * 8}s ${Math.random() * 6}s infinite linear;
    `;
    portal.appendChild(dot);
  }

  portal.innerHTML += `
    <div style="text-align:center;padding:0 20px;position:relative;z-index:2;">
      <div style="font-family:'Pinyon Script',cursive;font-size:clamp(2rem,8vw,3.5rem);color:rgba(255,220,160,0.95);text-shadow:0 0 40px rgba(255,180,100,0.5),0 0 80px rgba(200,100,255,0.3);letter-spacing:3px;margin-bottom:6px;animation:gkGlow 3s ease-in-out infinite alternate;">Eternal Sanctuary</div>
      <div style="font-size:clamp(0.7rem,2vw,0.85rem);color:rgba(200,180,255,0.6);letter-spacing:4px;text-transform:uppercase;margin-bottom:40px;">A private garden for two</div>
      
      <div id="gkStep1">
        <div style="font-size:clamp(0.85rem,2.5vw,1rem);color:rgba(255,240,210,0.8);margin-bottom:22px;font-style:italic;letter-spacing:1px;">Who seeks entry to this sanctuary?</div>
        <div style="display:flex;gap:14px;justify-content:center;flex-wrap:wrap;">
          <button class="gk-btn" data-user="khent" style="min-width:140px;">Khent</button>
          <button class="gk-btn" data-user="clair" style="min-width:140px;">Clair Jassen</button>
        </div>
      </div>

      <div id="gkStep2" style="display:none;">
        <div id="gkPrompt" style="font-size:clamp(0.85rem,2.5vw,1rem);color:rgba(255,240,210,0.8);margin-bottom:22px;font-style:italic;letter-spacing:1px;"></div>
        <input type="date" id="gkDatePicker" style="background:rgba(255,255,255,0.05);border:1px solid rgba(255,200,140,0.35);border-radius:10px;padding:12px 18px;color:rgba(255,235,210,0.9);font-family:'Cormorant Garamond',serif;font-size:1.1rem;text-align:center;outline:none;width:100%;max-width:240px;margin-bottom:18px;box-sizing:border-box;">
        <br>
        <button id="gkConfirm" class="gk-btn" style="min-width:180px;">Enter the Garden ✦</button>
        <br>
        <button id="gkBack" style="margin-top:12px;background:none;border:none;color:rgba(200,180,255,0.5);font-family:'Cormorant Garamond',serif;font-size:0.8rem;cursor:pointer;letter-spacing:1px;">← Go back</button>
      </div>

      <div id="gkError" style="color:rgba(255,100,100,0.9);font-style:italic;margin-top:14px;font-size:0.85rem;min-height:20px;"></div>
    </div>
  `;

  document.body.appendChild(portal);

  setupEventListeners(onUnlock);
}

function setupEventListeners(onUnlock) {
  // Step 1: User selection
  const userButtons = portal.querySelectorAll('.gk-btn[data-user]');
  userButtons.forEach(btn => {
    btn.addEventListener('click', () => {
      selectedUser = btn.dataset.user;
      portal.querySelector('#gkStep1').style.display = 'none';
      portal.querySelector('#gkStep2').style.display = 'block';
      portal.querySelector('#gkPrompt').textContent = `To prove your identity, enter your birth date:`;
      portal.querySelector('#gkError').textContent = '';
      if (navigator.vibrate) navigator.vibrate(30);
    });
  });

  // Back button
  const backBtn = portal.querySelector('#gkBack');
  backBtn.addEventListener('click', () => {
    selectedUser = null;
    portal.querySelector('#gkStep1').style.display = 'block';
    portal.querySelector('#gkStep2').style.display = 'none';
    portal.querySelector('#gkError').textContent = '';
  });

  // Step 2: Confirmation
  const confirmBtn = portal.querySelector('#gkConfirm');
  confirmBtn.addEventListener('click', () => {
    const val = portal.querySelector('#gkDatePicker').value;
    const errorEl = portal.querySelector('#gkError');
    const datePicker = portal.querySelector('#gkDatePicker');

    if (!val) {
      errorEl.textContent = 'Please select your birth date.';
      return;
    }

    if (val === BIRTHDAYS[selectedUser]) {
      // Success
      const userData = {
        name: selectedUser === 'khent' ? 'Khent' : 'Clair Jassen',
        key: selectedUser
      };
      
      Session.save(userData);
      unlockPortal(userData, onUnlock);
    } else {
      // Failure
      errorEl.textContent = '✦ The garden does not recognize this date. Try again.';
      if (navigator.vibrate) navigator.vibrate([80, 40, 80]);
      datePicker.style.borderColor = 'rgba(255,80,80,0.6)';
      setTimeout(() => {
        datePicker.style.borderColor = 'rgba(255,200,140,0.35)';
      }, 1500);
    }
  });
}

function unlockPortal(userData, onUnlock) {
  const viewport = document.getElementById('viewport');
  
  portal.style.transition = 'opacity 1.2s ease';
  portal.style.opacity = '0';
  
  if (viewport) {
    viewport.style.transition = 'filter 1.2s ease';
    viewport.style.filter = 'none';
    viewport.style.pointerEvents = 'auto';
  }

  if (navigator.vibrate) navigator.vibrate([30, 20, 60, 20, 30]);

  setTimeout(() => {
    portal.remove();
    showWelcomeBanner(userData.name);
    console.log('[Auth] ACCESS GRANTED — Welcome back,', userData.name);
    
    if (onUnlock) onUnlock(userData);
  }, 1200);
}

function showWelcomeBanner(userName) {
  const banner = document.createElement('div');
  banner.className = 'welcome-banner';
  banner.textContent = `Welcome, ${userName} 🌸`;
  document.body.appendChild(banner);
  
  setTimeout(() => {
    banner.remove();
  }, 5000);
}
