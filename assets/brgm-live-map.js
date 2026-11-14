/* Load the optional BRGM image only when its tab is selected. */
(() => {
  "use strict";
  const tab = document.getElementById("wms-tab-brgm");
  const panel = document.getElementById("wms-panel-brgm");
  if (!tab || !panel) return;
  const image = panel.querySelector(".brgm-live-image");
  const status = panel.querySelector(".wms-live-status");
  const fallback = panel.querySelector(".brgm-live-fallback");
  let requested = false;
  function requestWhenSelected() {
    if (requested || tab.getAttribute("aria-selected") !== "true") return;
    requested = true;
    status.textContent = "Loading the geological map from the BRGM service…";
    image.addEventListener("load", () => {
      image.hidden = false;
      status.textContent = "Live BRGM response loaded. See the source legend and notice to interpret geological units.";
    }, {once: true});
    image.addEventListener("error", () => {
      image.hidden = true;
      status.textContent = "The BRGM service did not return a displayable map for this request.";
      fallback.hidden = false;
    }, {once: true});
    image.src = image.dataset.src;
  }
  new MutationObserver(requestWhenSelected).observe(tab, {attributes: true, attributeFilter: ["aria-selected"]});
  requestWhenSelected();
})();
