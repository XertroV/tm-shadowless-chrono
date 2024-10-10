void Main() {
    startnew(CMapLoop);
}

void OnDestroyed() { Unload(); }
void OnDisabled() { Unload(); }
void Unload() { }
void OnEnabled() { startnew(CMapLoop); }

uint loopNonce = 0;
void CMapLoop() {
    auto myNonce = ++loopNonce;
    auto app = cast<CGameManiaPlanet>(GetApp());
    auto net = app.Network;
    while (myNonce == loopNonce) {
        yield();
        while (net.ClientManiaAppPlayground is null) yield();
        AwaitGetMLObjs(myNonce);
        while (net.ClientManiaAppPlayground !is null) yield();
    }
}

void AwaitGetMLObjs(uint _nonce) {
    auto net = cast<CTrackManiaNetwork>(GetApp().Network);
    if (net.ClientManiaAppPlayground is null) throw('null cmap');
    while (_nonce == loopNonce && net.ClientManiaAppPlayground !is null) {
        trace('getting pages');
        auto mlPages = net.GetManialinkPages();
        trace('mlPages.L =' + mlPages.Length);
        for (uint i = 0; i < mlPages.Length; i++) {
            auto page = mlPages[i];
            if (page is null) continue;
            // trace('url: ' + page.Url);
            if (page.Url == "<Old XMLRPC Deprecated>" && page.MainFrame.Controls.Length > 0 && page.MainFrame.Controls[0].Visible) {
                page.MainFrame.Controls[0].Visible = false;
            }
        }
        trace('done pages');
        sleep(1000);
    }
}
