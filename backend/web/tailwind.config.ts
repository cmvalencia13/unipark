import type { Config } from "tailwindcss";

const config: Config = {
  content: ["./src/**/*.{js,ts,jsx,tsx,mdx}"],
  darkMode: "class",
  theme: {
    extend: {
      fontFamily: {
        sans: ["Sora", "sans-serif"],
      },
      colors: {
        background: "#111317",
        surface: "#1a1d23",
        foreground: "#e2e2e8",
      },
    },
  },
  plugins: [],
};

export default config;
