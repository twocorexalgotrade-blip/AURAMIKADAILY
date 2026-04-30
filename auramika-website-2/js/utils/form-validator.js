// ===================================
// FORM VALIDATION UTILITY
// Client-side form validation
// ===================================

class FormValidator {
    constructor(formElement, options = {}) {
        this.form = formElement;
        this.options = {
            errorClass: 'error',
            successClass: 'success',
            errorMessageClass: 'error-message',
            ...options
        };

        this.rules = {};
        this.init();
    }

    init() {
        this.form.addEventListener('submit', this.handleSubmit.bind(this));

        // Add real-time validation
        const inputs = this.form.querySelectorAll('input, textarea, select');
        inputs.forEach(input => {
            input.addEventListener('blur', () => this.validateField(input));
            input.addEventListener('input', () => this.clearError(input));
        });
    }

    addRule(fieldName, rules) {
        this.rules[fieldName] = rules;
        return this;
    }

    validateField(field) {
        const fieldName = field.name;
        const value = field.value.trim();
        const rules = this.rules[fieldName];

        if (!rules) return true;

        // Required validation
        if (rules.required && !value) {
            this.showError(field, rules.requiredMessage || 'This field is required');
            return false;
        }

        // Email validation
        if (rules.email && value && !Utils.isValidEmail(value)) {
            this.showError(field, rules.emailMessage || 'Please enter a valid email');
            return false;
        }

        // Phone validation
        if (rules.phone && value && !Utils.isValidPhone(value)) {
            this.showError(field, rules.phoneMessage || 'Please enter a valid phone number');
            return false;
        }

        // Min length validation
        if (rules.minLength && value.length < rules.minLength) {
            this.showError(field, rules.minLengthMessage || `Minimum ${rules.minLength} characters required`);
            return false;
        }

        // Max length validation
        if (rules.maxLength && value.length > rules.maxLength) {
            this.showError(field, rules.maxLengthMessage || `Maximum ${rules.maxLength} characters allowed`);
            return false;
        }

        // Pattern validation
        if (rules.pattern && value && !rules.pattern.test(value)) {
            this.showError(field, rules.patternMessage || 'Invalid format');
            return false;
        }

        // Custom validation
        if (rules.custom && !rules.custom(value, field)) {
            this.showError(field, rules.customMessage || 'Validation failed');
            return false;
        }

        this.clearError(field);
        this.showSuccess(field);
        return true;
    }

    validateForm() {
        let isValid = true;
        const fields = this.form.querySelectorAll('input, textarea, select');

        fields.forEach(field => {
            if (!this.validateField(field)) {
                isValid = false;
            }
        });

        return isValid;
    }

    handleSubmit(e) {
        e.preventDefault();

        if (this.validateForm()) {
            // Form is valid, proceed with submission
            if (this.options.onSubmit) {
                this.options.onSubmit(this.getFormData());
            }
        } else {
            // Focus on first error field
            const firstError = this.form.querySelector(`.${this.options.errorClass}`);
            if (firstError) {
                firstError.focus();
                firstError.scrollIntoView({ behavior: 'smooth', block: 'center' });
            }
        }
    }

    showError(field, message) {
        this.clearError(field);

        field.classList.add(this.options.errorClass);
        field.classList.remove(this.options.successClass);

        const errorDiv = document.createElement('div');
        errorDiv.className = this.options.errorMessageClass;
        errorDiv.textContent = message;
        errorDiv.style.cssText = 'color: #DC2626; font-size: 12px; margin-top: 4px;';

        field.parentElement.appendChild(errorDiv);
    }

    clearError(field) {
        field.classList.remove(this.options.errorClass);

        const errorMessage = field.parentElement.querySelector(`.${this.options.errorMessageClass}`);
        if (errorMessage) {
            errorMessage.remove();
        }
    }

    showSuccess(field) {
        field.classList.add(this.options.successClass);
    }

    getFormData() {
        const formData = new FormData(this.form);
        const data = {};

        for (const [key, value] of formData.entries()) {
            data[key] = value;
        }

        return data;
    }

    reset() {
        this.form.reset();
        const fields = this.form.querySelectorAll('input, textarea, select');
        fields.forEach(field => {
            this.clearError(field);
            field.classList.remove(this.options.successClass);
        });
    }
}

// Export for use in other modules
if (typeof module !== 'undefined' && module.exports) {
    module.exports = FormValidator;
}
