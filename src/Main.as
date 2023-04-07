void Main() {
    startnew(CMapLoop);
}

void OnDestroyed() { Unload(); }
void OnDisabled() { Unload(); }
void Unload() { ResetChronoStyle(); }
void OnEnabled() {
    try {
        AwaitGetMLObjs(); // can throw outside PG, just ignore
    } catch {}
 }

// note: we actually set frame-chrono to @ChronoFrame -- the child of Race_Chrono
const string ChronoFrameId = "Race_Chrono";

void CMapLoop() {
    auto app = cast<CGameManiaPlanet>(GetApp());
    auto net = app.Network;
    while (true) {
        yield();
        while (net.ClientManiaAppPlayground is null) yield();
        AwaitGetMLObjs();
        while (net.ClientManiaAppPlayground !is null) yield();
        @ChronoFrame = null;
        count = 0;
    }
}

CGameManialinkFrame@ ChronoFrame = null;

uint count = 0;
void AwaitGetMLObjs() {
    auto net = cast<CTrackManiaNetwork>(GetApp().Network);
    if (net.ClientManiaAppPlayground is null) throw('null cmap');
    auto cmap = net.ClientManiaAppPlayground;
    while (cmap.UILayers.Length < 7) yield();
    count = 0;
    while (ChronoFrame is null) {
        sleep(50);
        for (uint i = 0; i < cmap.UILayers.Length; i++) {
            auto layer = cmap.UILayers[i];
            if (!layer.IsLocalPageScriptRunning || !layer.IsVisible || layer.LocalPage is null) continue;
            auto frame = cast<CGameManialinkFrame>(layer.LocalPage.GetFirstChild(ChronoFrameId));
            if (frame is null || frame.Controls.Length < 1) continue;
            @frame = cast<CGameManialinkFrame>(frame.Controls[0]);
            if (frame is null || frame.Controls.Length < 1) continue;
            @ChronoFrame = frame;
            break;
        }
        count++;
        // if (ChronoFrame is null && count < 50) trace('not found');
        if (count > 50) {
            warn('ML not found, not updating ML props');
            return;
        }
    }
    startnew(UpdateChronoStyle);
}

void UpdateChronoStyle() {
    if (ChronoFrame is null) throw('unexpected null ChronoFrame');
    if (ChronoFrame.Controls.Length < 1) throw('helper frame controls < 1');
    auto label = ChronoFrame.Controls[0];
    if (label is null) throw('null label');
    label.Control.Style.LabelForceEmbossed = false;
}

void ResetChronoStyle() {
    if (ChronoFrame is null) return;
    try {
        ChronoFrame.Controls[0].Control.Style.LabelForceEmbossed = true;
    } catch {
        warn('Resetting chrono style exception: ' + getExceptionInfo());
    }
}
