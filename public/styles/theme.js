// public/styles/theme.js
(function () {
  const KEY = "fase1-theme";
  const root = document.documentElement;

  function systemPref() {
    return window.matchMedia && window.matchMedia("(prefers-color-scheme: light)").matches ? "light" : "dark";
  }

  function apply(theme) {
    root.setAttribute("data-theme", theme);
    const meta = document.querySelector('meta[name="color-scheme"]');
    if (meta) meta.setAttribute("content", theme === "light" ? "light dark" : "dark light");
  }

  function current() {
    return localStorage.getItem(KEY) || systemPref();
  }

  function toggle() {
    const t = current() === "light" ? "dark" : "light";
    localStorage.setItem(KEY, t);
    apply(t);
  }

  apply(current());
  window.addEventListener("DOMContentLoaded", () => {
    const btn = document.getElementById("themeToggle");
    if (btn) btn.addEventListener("click", toggle);
  });
})();
