/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./public/*.html",
    "./app/helpers/**/*.rb",
    "./app/javascript/**/*.js",
    "./app/views/**/*.{erb,haml,html,slim}",
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ["system-ui", "Segoe UI", "Roboto", "Helvetica Neue", "Arial", "sans-serif"],
      },
      colors: {
        'earth-base': 'var(--bg-base)',
        'earth-muted': 'var(--bg-muted)',
        'earth-soft-green': 'var(--bg-soft-green)',
        'earth-accent': 'var(--accent-warm)',
        'border-main': 'var(--border-color)',
        'border-strong': 'var(--border-strong)'
      },
      borderRadius: {
        'md-custom': 'var(--border-radius)'
      },
      borderWidth: {
        'strong': 'var(--border-strong-width)'
      }
    },
  },
  plugins: [],
};
