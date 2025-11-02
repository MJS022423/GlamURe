/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,jsx,ts,tsx}",
  ],
  
  theme: {
    extend: {
      keyframes: {
        'bounce-bar': {
          '0%, 100%': { transform: 'scaleY(0.4)' },
          '50%': { transform: 'scaleY(1.5)' },
        },
      },
      animation: {
        'bounce-bar': 'bounce-bar 1s ease-in-out infinite',
      },
    },
  },
  plugins: [],
}
