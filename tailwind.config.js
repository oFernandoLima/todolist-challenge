module.exports = {
  content: [
    "./app/views/**/*.{html,erb}",
    "./app/helpers/**/*.rb",
    "./app/assets/javascripts/**/*.js",
    "./app/assets/stylesheets/**/*.css",
    "./app/assets/tailwind/**/*.css",
  ],
  theme: {
    extend: {},
  },
  plugins: [require("daisyui")],
};
