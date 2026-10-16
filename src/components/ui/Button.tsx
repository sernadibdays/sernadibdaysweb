import React from 'react';
import { Link } from 'react-router-dom';

interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'secondary' | 'outline' | 'ghost';
  size?: 'sm' | 'md' | 'lg';
  href?: string;
  to?: string;
}

export const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className = '', variant = 'primary', size = 'md', href, to, children, ...props }, ref) => {
    const baseStyles = 'inline-flex items-center justify-center rounded-md font-medium transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary disabled:pointer-events-none disabled:opacity-50';
    const variants = {
      primary: 'bg-primary text-white hover:bg-primary-600',
      secondary: 'bg-accent text-white hover:bg-accent-600',
      outline: 'border-2 border-primary text-primary hover:bg-primary-50',
      ghost: 'hover:bg-slate-100 text-slate-700',
    };
    const sizes = {
      sm: 'h-9 px-3 text-sm',
      md: 'h-11 px-6',
      lg: 'h-14 px-8 text-lg',
    };

    const combinedClassName = `${baseStyles} ${variants[variant]} ${sizes[size]} ${className}`;

    if (to) {
      return <Link to={to} className={combinedClassName}>{children}</Link>;
    }

    if (href) {
      return <a href={href} className={combinedClassName}>{children}</a>;
    }

    return (
      <button ref={ref} className={combinedClassName} {...props}>
        {children}
      </button>
    );
  }
);
Button.displayName = 'Button';
