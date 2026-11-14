/* Independent, accessible tabs for each projection comparison. */
(() => {
  "use strict";
  document.querySelectorAll(".projection-tabs").forEach((group) => {
    const tabs = Array.from(group.querySelectorAll('[role="tab"]'));
    const panels = tabs.map((tab) => document.getElementById(tab.getAttribute("aria-controls")));
    if (!tabs.length || panels.some((panel) => !panel)) return;
    function activate(index, moveFocus = false) {
      tabs.forEach((tab, i) => {
        tab.setAttribute("aria-selected", String(i === index));
        tab.tabIndex = i === index ? 0 : -1;
        panels[i].hidden = i !== index;
      });
      if (moveFocus) tabs[index].focus();
    }
    tabs.forEach((tab, index) => {
      tab.addEventListener("click", () => activate(index));
      tab.addEventListener("keydown", (event) => {
        let next;
        if (event.key === "ArrowRight") next = (index + 1) % tabs.length;
        else if (event.key === "ArrowLeft") next = (index + tabs.length - 1) % tabs.length;
        else if (event.key === "Home") next = 0;
        else if (event.key === "End") next = tabs.length - 1;
        else return;
        event.preventDefault();
        activate(next, true);
      });
    });
    activate(Math.max(0, tabs.findIndex((tab) => tab.getAttribute("aria-selected") === "true")));
  });
})();
