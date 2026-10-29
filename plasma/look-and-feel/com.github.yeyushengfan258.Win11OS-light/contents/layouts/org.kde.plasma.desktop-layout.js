// Win11OS default layout: a single bottom taskbar that mimics Windows 11.
// Start menu on the left, centred task buttons, system tray and clock on the right.

var panel = new Panel

panel.location = "bottom"
panel.height = 48

panel.addWidget("org.kde.plasma.kickoff")

var leftSpacer = panel.addWidget("org.kde.plasma.panelspacer")
leftSpacer.expanding = true

panel.addWidget("org.kde.plasma.icontasks")

var rightSpacer = panel.addWidget("org.kde.plasma.panelspacer")
rightSpacer.expanding = true

panel.addWidget("org.kde.plasma.systemtray")
panel.addWidget("org.kde.plasma.digitalclock")

var desktopsArray = desktopsForActivity(currentActivity())
for (var i = 0; i < desktopsArray.length; i++) {
    desktopsArray[i].wallpaperPlugin = "org.kde.image"
}
