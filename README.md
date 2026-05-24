# Helping-Hand

<a href="https://github.com/gruvw/helping-hand/releases/latest" target="_blank"><img src="https://img.shields.io/github/v/release/gruvw/helping-hand?style=for-the-badge&color=04cc04" alt="Latest Release Badge" /></a>

Trigger any button on any remote control using your digital devices.

<img width="600" src="./docs/images/finished_perspective.jpg">

This project started from a simple observation: many things already present in our homes are not "smart" or connected although they have a remote controller (blinds, garage doors, air conditionning, etc), and when they are they often each have their own separate mobile application.
On top of that, those applications are often poorly designed, requiring you to create an account to log in, they aren't cross-platform (meaning they are not accessible from a computer, or from a web browser, or only available on iOS/Android), and are very rarely thought with accessibily in mind.

So instead of replacing a whole perfectly working home appliance to install a commertial "smart" one that comes with the flaws mentionned above, Helping-Hand is an inexpensive solution that adapts to your existing remote controllers.
You can install a remote control inside the device, and configure a small servo motor module for each button that you want to control on it.
The device turns your regular remote control into a connected appliance, controllable from a cross-platform application available on your smartphone, tablet and computer.

You can checkout a short video demo of the system, with a focus on its accessibility features: <https://youtu.be/LdWC4-ZtAj0>.

Take a look at the project's [roadmap](docs/roadmap.md) to see upcoming features (along with all the work accomplished).

**Note**: currently the project's focus is to adapt radio based remote controls, which are significantly harder to recreate than infrared (IR) based ones because of security reasons.
Although the current device can work for IR based remotes, it probably won't be the most appropriate solution.
The goal is to later create another device that integrates into the same system, dedicated to IR remotes, that will be able to record and replay basic IR commands, meaning in won't even require the original remote itself or servo motors.

## Phylosophy

The core principles of the project are the following:

- **Simplicity**: keep every component as straightforward as possible, complexity is only introduced when strictly necessary; makes the system easier to understand, maintain, and debug.
- **Modularity**: allows for using only what you need (nothing more), replacing just the parts that needs to be (repairability), faster development cycle (iterating only on parts of the system).
- **Open-Source**: source code, schematics, and designs are fully available and free to inspect, modify, and distribute; this encourages community contributions, trust through transparency, and freedom from vendor lock-in.
- **Accessibility**: being as inclusive as possible, empowering users with unique needs to control their environment and regain some autonomy.
- **Efficiency**: keep the system responsive and lean, make actions fast by minimizing latency and loading states where possible.
- **Extensibility**: designed to be extended, new remotes, arms, rails, components, transports, or platforms can be added without rearchitecting what already works.

These principles are fundamental to all parts of the project, whether it is System Design, Hardware, Firmware or Software; both in the user facing parts and on the development end.

## Hardware

price

## Firmware

### Dev environment

## Software

### User interface

The companion app that allows controlling over the Helping-Hand devices has the following user interface.

<img width="250" src="./docs/images/app/home.jpg">

When opening the app, the user is directly presented with the home screen above.
Here they can find their different remotes and actions organized in tiles.

There are three types of tiles, each with a separate icon and color:

- Folder tiles in orange: allows grouping other tiles under a common and named place; the system allows for nesting folders as deeply as necessary.
- Remote tiles in green: access all the buttons configured on that remote.
- Action tiles in purple: clicking on this type of tile will trigger a click on the corresponding button of that remote

In a folder (or on the home page), the user can long press on tiles to reorder them to their liking.
Remote tiles only contains all of the actions configure on the corresponding remote, while folder tiles (and the home screen) can contain any type of tiles: folders, remotes, and action tiles directly. This allows for quick actions directly from the home screen for example, or creating a folder containing a subset of buttons from a given remote.

A remote's configuration is directly stored on the Helping-Hand device itself, not locally on a user's application.
Editing a remote's configuration (renaming it, adding or changing its actions, ...) is done on this page and will be directly available to any other user having this remote installed in their application.
This is voluntarily kept seprate from the user's tiles referencing those remotes and actions, so that different users can organize their tiles to their liking, on each of their device.

#### Accessibily mode

In this mode, other main screen actions (like drag and drop to reorder) are not enabled to avoid involuntary actions resulting from harder to control input systems.
The top application's bar however is still enabled as it is used to access settings to disable the accessibility mode.

**Note**: the "Use HTTPs" toggle is explained below (see [Note on iOS devices](#note-on-ios-devices)).

#### Logo

<img width="100" src="./docs/images/app/logo.png">

The image above is the Helping-Hand's logo.

It is used as the application icon, the web application's favicon, and displayed in the starting flash screen when opening the app.

It's designs follows the minimalistic and efficient look of the app.
The logo bears a dual meaning: first it represents a home laying on its side because this system is made for home automation, and it looks a bit like a "play" or "do it" button icon representing the act of performing an action like the button presses.

### Dev environment

### Browser Security

#### Note on iOS devices

## Security
