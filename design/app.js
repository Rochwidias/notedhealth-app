/* NotedHealth mockup — interaktivitas hybrid (vanilla JS) */

(function () {
  "use strict";

  /* ---------- toggle terang / gelap (galeri + sakelar di dalam app) ---------- */
  const themeBtn = document.getElementById("themeToggle");
  const syncThemeLabel = () => {
    if (!themeBtn) return;
    const dark = document.body.classList.contains("dark");
    const en = document.documentElement.dataset.lang === "en";
    document.getElementById("themeLabel").textContent = dark
      ? en ? "Light mode" : "Mode terang"
      : en ? "Dark mode" : "Mode gelap";
  };
  const applyDark = (dark) => {
    document.body.classList.toggle("dark", dark);
    if (themeBtn) themeBtn.setAttribute("aria-pressed", String(dark));
    document
      .querySelectorAll("[data-dark]")
      .forEach((sw) => sw.setAttribute("aria-checked", String(dark)));
    syncThemeLabel();
  };
  if (themeBtn) {
    themeBtn.addEventListener("click", () => {
      applyDark(!document.body.classList.contains("dark"));
    });
  }
  document.addEventListener("langchange", syncThemeLabel);

  /* sakelar Mode gelap di dalam app (Profil) */
  document.querySelectorAll("[data-dark]").forEach((sw) => {
    sw.addEventListener("click", () => {
      applyDark(sw.getAttribute("aria-checked") !== "true");
    });
  });

  /* ---------- FAB: buka/tutup menu aksi cepat ---------- */
  document.querySelectorAll("[data-fab]").forEach((fab) => {
    const menu = document.getElementById(fab.getAttribute("data-fab"));
    const scrim = fab.parentElement.querySelector(".scrim");
    const close = () => {
      fab.setAttribute("aria-expanded", "false");
      if (menu) menu.hidden = true;
      if (scrim) scrim.hidden = true;
    };
    const open = () => {
      fab.setAttribute("aria-expanded", "true");
      if (menu) menu.hidden = false;
      if (scrim) scrim.hidden = false;
    };
    fab.addEventListener("click", () => {
      fab.getAttribute("aria-expanded") === "true" ? close() : open();
    });
    if (scrim) scrim.addEventListener("click", close);
  });

  /* ---------- bottom sheet: buka/tutup ---------- */
  document.querySelectorAll("[data-sheet-close]").forEach((btn) => {
    btn.addEventListener("click", () => {
      const sheet = document.getElementById(btn.getAttribute("data-sheet-close"));
      if (sheet) sheet.hidden = true;
      const screen = btn.closest(".screen");
      if (screen) screen.querySelectorAll(".scrim").forEach((s) => (s.hidden = true));
    });
  });
  document.querySelectorAll("[data-sheet-open]").forEach((btn) => {
    btn.addEventListener("click", () => {
      const sheet = document.getElementById(btn.getAttribute("data-sheet-open"));
      const screen = btn.closest(".screen");
      if (screen) {
        screen.querySelectorAll(".scrim").forEach((s) => {
          s.hidden = false;
          s.addEventListener("click", () => {
            s.hidden = true;
            if (sheet) sheet.hidden = true;
          });
        });
      }
      if (sheet) sheet.hidden = false;
    });
  });

  /* ---------- checklist: centang habit ---------- */
  document.querySelectorAll(".check").forEach((cb) => {
    cb.addEventListener("click", () => {
      const on = cb.getAttribute("aria-checked") === "true";
      cb.setAttribute("aria-checked", String(!on));
      const row = cb.closest(".habit");
      if (row) row.classList.toggle("done", !on);
    });
  });

  /* ---------- switch: reminder, aktif/nonaktif (Mode gelap pakai jalur data-dark) ---------- */
  document.querySelectorAll(".switch:not([data-dark])").forEach((sw) => {
    sw.addEventListener("click", () => {
      const on = sw.getAttribute("aria-checked") === "true";
      sw.setAttribute("aria-checked", String(!on));
    });
  });

  /* ---------- segmented control (7/30 hari) ---------- */
  document.querySelectorAll(".seg").forEach((seg) => {
    seg.querySelectorAll("button").forEach((b) => {
      b.addEventListener("click", () => {
        seg.querySelectorAll("button").forEach((x) => x.setAttribute("aria-pressed", "false"));
        b.setAttribute("aria-pressed", "true");
      });
    });
  });

  /* ---------- chip pilihan tunggal (kategori, filter, emoji habit) ---------- */
  document.querySelectorAll("[data-single]").forEach((row) => {
    const items = row.querySelectorAll(".chip, .emoji");
    items.forEach((chip) => {
      chip.addEventListener("click", () => {
        items.forEach((c) => {
          c.classList.remove("on");
          c.setAttribute("aria-pressed", "false");
        });
        chip.classList.add("on");
        chip.setAttribute("aria-pressed", "true");
        const big = row.closest(".field") && row.closest(".field").querySelector(".emoji-big");
        if (big && chip.classList.contains("emoji")) big.textContent = chip.textContent;
      });
    });
  });

  /* ---------- pemilih bahasa ID/EN di dalam app (Profil) ---------- */
  const syncLangSeg = () => {
    const cur = document.documentElement.dataset.lang || "id";
    document.querySelectorAll("[data-lang]").forEach((b) => {
      const on = b.getAttribute("data-lang") === cur;
      b.classList.toggle("on", on);
      b.setAttribute("aria-pressed", String(on));
    });
  };
  document.querySelectorAll("[data-lang]").forEach((b) => {
    b.addEventListener("click", () => {
      if (window.nhI18n) window.nhI18n.set(b.getAttribute("data-lang"));
    });
  });
  document.addEventListener("langchange", syncLangSeg);
  syncLangSeg();

  /* ---------- snackbar error: tombol coba lagi ---------- */
  document.querySelectorAll(".snackbar .retry").forEach((btn) => {
    btn.addEventListener("click", () => {
      const bar = btn.closest(".snackbar");
      if (bar) bar.remove();
    });
  });
})();
