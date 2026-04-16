// VacanSee Login Page JavaScript
// Handles form validation, password toggle, and navigation

/**
 * Initialize all event listeners when DOM is ready
 */
document.addEventListener('DOMContentLoaded', function() {
    const loginForm = document.getElementById('loginForm');
    const togglePassword = document.getElementById('togglePassword');
    const passwordInput = document.getElementById('password');
    const roleSelect = document.getElementById('role');

    // Form submission
    loginForm.addEventListener('submit', handleLogin);

    // Password visibility toggle
    togglePassword.addEventListener('click', togglePasswordVisibility);

    // Role selection change
    roleSelect.addEventListener('change', handleRoleChange);

    // Real-time validation
    document.getElementById('email').addEventListener('blur', validateEmail);
    document.getElementById('password').addEventListener('blur', validatePassword);
    document.getElementById('role').addEventListener('blur', validateRole);

    // Clear errors on input
    document.querySelectorAll('.form-input').forEach(input => {
        input.addEventListener('input', clearError);
    });
});

/**
 * Handle login form submission
 * @param {Event} e - Form submit event
 */
function handleLogin(e) {
    e.preventDefault();

    // Validate all fields
    const isRoleValid = validateRole();
    const isEmailValid = validateEmail();
    const isPasswordValid = validatePassword();

    if (isRoleValid && isEmailValid && isPasswordValid) {
        const role = document.getElementById('role').value;
        
        // Navigate to role-specific dashboard
        let dashboardUrl;
        switch(role) {
            case 'tenant':
                dashboardUrl = '/tenant-dashboard.html';
                break;
            case 'owner':
                dashboardUrl = '/owner-dashboard.html';
                break;
            case 'admin':
                dashboardUrl = '/admin-dashboard.html';
                break;
            default:
                dashboardUrl = '/landing.html';
        }

        // Simulate login delay
        const loginBtn = document.querySelector('.btn-login');
        const originalText = loginBtn.textContent;
        loginBtn.textContent = 'Logging in...';
        loginBtn.disabled = true;

        setTimeout(() => {
            window.location.href = dashboardUrl;
        }, 1000);
    }
}

/**
 * Toggle password visibility
 */
function togglePasswordVisibility() {
    const passwordInput = document.getElementById('password');
    const toggleBtn = document.getElementById('togglePassword');

    if (passwordInput.type === 'password') {
        passwordInput.type = 'text';
        toggleBtn.innerHTML = `
            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"></path>
                <line x1="1" y1="1" x2="23" y2="23"></line>
            </svg>
        `;
    } else {
        passwordInput.type = 'password';
        toggleBtn.innerHTML = `
            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path>
                <circle cx="12" cy="12" r="3"></circle>
            </svg>
        `;
    }
}

/**
 * Handle role selection change
 */
function handleRoleChange() {
    const role = this.value;
    if (role) {
        // Could add role-specific UI changes here
        console.log('Role selected:', role);
    }
}

/**
 * Validate role selection
 * @returns {boolean} - True if valid
 */
function validateRole() {
    const role = document.getElementById('role');
    const error = document.getElementById('roleError');

    if (!role.value) {
        role.classList.add('error');
        error.classList.add('show');
        return false;
    }

    role.classList.remove('error');
    error.classList.remove('show');
    return true;
}

/**
 * Validate email
 * @returns {boolean} - True if valid
 */
function validateEmail() {
    const email = document.getElementById('email');
    const error = document.getElementById('emailError');
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

    if (!email.value.trim() || !emailRegex.test(email.value)) {
        email.classList.add('error');
        error.classList.add('show');
        return false;
    }

    email.classList.remove('error');
    error.classList.remove('show');
    return true;
}

/**
 * Validate password
 * @returns {boolean} - True if valid
 */
function validatePassword() {
    const password = document.getElementById('password');
    const error = document.getElementById('passwordError');

    if (!password.value || password.value.length < 6) {
        password.classList.add('error');
        error.classList.add('show');
        return false;
    }

    password.classList.remove('error');
    error.classList.remove('show');
    return true;
}

/**
 * Clear error on input
 */
function clearError() {
    this.classList.remove('error');
    const errorId = this.id + 'Error';
    const error = document.getElementById(errorId);
    if (error) {
        error.classList.remove('show');
    }
}

/**
 * Navigate to a specific path
 * @param {string} path - The path to navigate to
 */
function navigateTo(path) {
    window.location.href = path;
}
