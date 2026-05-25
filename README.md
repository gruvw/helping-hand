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

The device itself is composed of 3D printed parts, and some easy to find electronics components.
The image below shows the basic parts required to build a Helping-Hand device.

<img width="600" src="./docs/images/module_components_required.jpg">

### 3D Printing

You can find all the CAD models used for this project under the `cad` directory.
It is composed of three main parts.
All the parts can be 3D printed without supports, at 15% infill, and using regular PLA filament.

**1. The Device**

<img width="500" src="./docs/images/device_cad.png">

This is the body of the system.
It has a main box compartement where goes the electronics.
This is closed by placing the main vice rail on top of it, and they are held together my a regular M4 bolt and a square nut.
The vice comes on the side of the rail and slides in.
Then we can pass a 130mm M6 bolt inside into a pressure fit M6 square nut on the other end.
Those are the only two screws of the main body.

Then comes the two rails from the side of the device.
They are pressure fit in place in the two corresponding holes.
The servo modules can be screwed on those rails using a short M4 bolt and a square nut under the rail.

**2. The Vicers Attachements**

Most remotes will be held in place just fine using the regular inside of the vice's walls. 

However, some remotes might require adding special attachement in order to be properly secured in place.

<img width="500" src="./docs/images/vicers_cad.png">

Here are a few, ready-to-print attachements that should cover most needs.
There's one for small rounded remotes and another one for remotes with angled edges for example.
Those attachements are simply slided into the main body using the small inner rails on the vice's walls.

One of those attachements will require the use of a 2mm thick soft silicone sheet; it is used to have a better grip on some remotes.

**3. The Arms**

<img width="500" src="./docs/images/arms_cad.png">

There are already three sizes of arms attachements available.
They are built to clip directly inside a buckle, glued on a servo's plastic arm.

<img width="300" src="./docs/images/servo_attachement_glue.jpg">

Those are designed to be easily swapped if needed.

In order to print everything required to build a Helping-Hand module with 4 servo attachement, it takes approximately **5 hours of print time and 200 grams of filament**, depending on your printer and your settings.

The whole mechanical designed is really built with modularity in mind.
There are a total of 4 points of interface:

- The servo rails holes on the side can accommodate different rails if required.
- The vicer attachement system can fit any kind of custom designed walls as long as they have the slit rails to be slidded onto the vice's inner walls.
- The servo modules can be swapped to use different kinds of servo, or have some other form of orientation for example.
- The servo buckle can be used with all sort of arms as long as they have the same base clip.

Those are here for 3 main reasons:

- If a part breaks, like an arm, a rail or a servo module, you only need to replace that part and not the whole device.
- If a part does not fit your need, like if there's a really special remote, you can create your own and make it work with the rest of the device.
- Only use the number of parts required for the application, like if you only need to access one button, you might only use a single rail and a single servo module.

### Electronics

<img width="600" src="./docs/images/full_electronics.jpg">

The electronics required for building a module is the following:

- A 5V 3A alimentation
- An ESP-32 C6 microcontroller
- A PCA9685 servo controller
- Some MG90S servo motors
- A DC plug
- Electronics wires
- (optionnaly) Some JR servo connectors

The image below describes the wiring schematics for the system:

<img width="500" src="./docs/images/electronics_schematic.jpg">

Once you connect everything together it should look something like the following:

<img width="500" src="./docs/images/electronics_wiring.jpg">

You can then install the electronics inside the main body of the system.
Regular hot glue can be used to fix the components and a stronger glue can be used to hold the cable connectors to the walls.

<img width="500" src="./docs/images/module_inside.jpg">

### Finished device

A fully finished and assembled system looks like the following:

<img width="600" src="./docs/images/module_components_finished.jpg">

When accounting for all the materials necessary, the total cost for building a full device is approximately **46$**, and it should take about **2 hours** to fully assemble (not accounting for 3D printing time).

## Firmware

The firmware code for the ESP-32 C6 microcontroller is built in [Rust](https://rust-lang.org/).
The code is under the `firmware` directory.

It uses a modularized architecture with 5 main parts:

- The network part is responsible for connecting to the Wi-Fi router and runs a reconnection mechanism every 30 seconds in case the connection drops.
- The server part is responsible for running an HTTP (and an HTTPs) server in order to recieve and dispatch requests.
- The logic part is responsible for handling the requests.
- The servo part exposes an API to control the servo motors through the PCA9685 running via I2C.
- The filesystem part is used to persist the configuration of the device through reboots.

The system is configured using a `.env` file containing the following information:

```env
# .env

DEVICE_ID="0001"

NET_SSID="Helping-Hand"
NET_PWD="hh-test-net"
```

### Dev environment

In order to compile and flash the system you will need to install the required dependencies.

This process is simplified by using a nix `flake.nix` file.

You simply need to run `nix develop` inside the `firmware` directory to have everything ready to go.
Learn more about nix flakes here: <https://wiki.nixos.org/wiki/Flakes>

Once all the dependencies are installed, you can run `cargo build` to build the firmware, and `cargo run` to flash an ESP-32 C6 connected via USB.

## Software

The software code for the Helping-Hand companion application is built in [Dart](https://dart.dev/) using the [Flutter](https://flutter.dev/) framework.
The code is under the `app` directory.

### User interface

The companion app that allows controlling over the Helping-Hand devices has the following user interface.

<img width="250" src="./docs/images/app/home.jpg">

When opening the app, the user is directly presented with the home screen above.
Here they can find their different remotes and actions organized in tiles.

There are three types of tiles, each with a separate icon and color:

- Folder tiles in orange: allows grouping other tiles under a common and named place; the system allows for nesting folders as deeply as necessary.
- Remote tiles in green: access all the buttons configured on that remote.
- Action tiles in purple: clicking on this type of tile will trigger a click on the corresponding button of that remote

<img width="250" src="./docs/images/app/reorder.jpg">

In a folder (or on the home page), the user can long press on tiles and then drag and drop to reorder them to their liking.
Remote tiles only contains all of the actions configure on the corresponding remote, while folder tiles (and the home screen) can contain any type of tiles: folders, remotes, and action tiles directly. This allows for quick actions directly from the home screen for example, or creating a folder containing a subset of buttons from a given remote.

A remote's configuration is directly stored on the Helping-Hand device itself, not locally on a user's application.
Editing a remote's configuration (renaming it, adding or changing its actions, ...) is done on this page and will be directly available to any other user having this remote installed in their application.
This is voluntarily kept seprate from the user's tiles referencing those remotes and actions, so that different users can organize their tiles to their liking, on each of their device.

The user can use the following context menu to change things about the current view:

<img width="250" src="./docs/images/app/context_menu.jpg">

This allows for things like creating a new folder, renaming the current one or moving it to a different place for example.
The user can also select the "Remotes" option to access the following screen:

<img width="250" src="./docs/images/app/remotes.jpg">

From here the user can click on the "+" icons to add a remote or quick-action tile to the folder they were coming from.
It's also from here that the user can add and configure new remotes or buttons.

<img width="250" src="./docs/images/app/register_new_action.jpg">

The process to configure a new button is quite straightforward and follows the form's input from top to bottom.
First connect a servo module to one of the available port on the device.
Then select that port using the arrow keys at the top of the form.
Type in the name of that new button, and click on the "set" button.
This will bring down the arm connected to the selected servo module close to the remote.
You can then use the up and down buttons to bring the servo closer in order to align it properly to the button that you want to control.
Once it is aligned properly you can tighten the screw on the rail and proceed to the "click" test.
You can then click on the lowering button as many times as necessary, until you actually see the remote registering the click.
Then you can click on "Confirm" to save this new button.

#### Accessibily mode

This mode is specifically designed for people with disabilities that might use other input systems to use the application.
For them it might not be easy to point to the correct tile everytime, or it could induce strain and/or physical load.
On the home screen, the user can access the settings to enable the accessibility mode by clicking on "Use Accessible UI".

<img width="220" src="./docs/images/app/settings.jpg">

When returning to the home screen, the system automatically cycles through the tiles, highlighting each with a blue border one after the other.
Instead of needing to target a specific tile, the user can tap anywhere on the screen to select the currently highlighted option.
This drastically increases the active input area and eliminates the need for precise clicking.

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

Flutter is required to build and deploy the application.
You can follow the installation steps provided on the Flutter website for your system: <https://docs.flutter.dev/install>
Make sure the `flutter doctor -v` command runs without errors after installation.

In order to run the Helping-Hand application locally you can execute the `flutter run` command inside the `app` directory.

Additionnally, two build flags are available to facilitate the development of the app:

- `--dart-define=DEBUG_FAKE_REQUESTS=true`: this flag will enable a fake interface with two mocked devices `hh-0001` and `hh-0002`. All requests made will have a fake delay and a 30% failure rate to test how the UI handles those cases. (only has an effect when building for DEBUG mode)
- `--dart-define=DEBUG_ERASE_DB=true`: this flag will earase the local database on every build. This can be useful to start from a clean app and make sure there was no residual state potentially causing problems. (only has an effect when building for DEBUG mode)

## Security

As with any digital system, the security of Helping-Hand is important to discuss.

The main safe guard here is the access to your home Wi-Fi network.
Basically, any device that is connected to the same Wi-Fi network as a Helping-Hand device is considered trusted to execute actions and re-configure the device.
Devices outside that network will however have no direct access to the device.

This security model therefore relies on having a strong and secure Wi-Fi password.
It also improses a limitation on the system, which is that it cannot be controlled if you are not connected to your home Wi-Fi.
It means that it's not possible to use the system to open and close the blinds when your are away for vacations for example.

Although because the system is built with extensibility in mind, one could have a proxy device like a laptop or a small raspberry pi, connected to the internet and and execute internal requests based on external commands.
Another solution could be to use a regular home VPN server.
However this would increase the attack surface of the whole system and their security must be assured.

### Browser Security

Although the Helping-Hand user interface is built with Flutter for cross-platform support, it currently only supports the web target.
That means that it has to follow the browser security model and account for CSRF protection and mixed-content policies.

The user interface web application has to be servered over HTTPs, not only because of security concerns, but also because it uses the web worker api and local storage features which both require the site to be served over a secured connection.
It implies that any requests the website wants to make also has to conform to that HTTPs protocol, as per the mixed-content policy.
However the ESP32 microcontrollers aren't full on computers and are a little bit on the low ends of performances of what's necessary in terms of memory and CPU to handle HTTPs connections.

Luckly for the project, a modern browser feature called [Local Network Access](https://wicg.github.io/local-network-access/) (LNA) allows to make HTTP requests to local network devices, even from an HTTPs served website, therefore bypassing the mixed-content policy.
It just asks for the user to confirm that a given website is indeed authorized to make such requests by showing a confirmation pop-up dialog once.
The firmware is configured to adhere to the specification of LNA and has the correct request preflight headers setup properly to tell the browser that this feature is indeed supported.

Additionnally, to prevent cross site request forgery, the ESP-32 must respond to any request by filling the allow origin headers.
In debug mode it will allow any port of the `localhost` origin, and in release mode the firmware only allows requests from a hardcoded URL, defaulting to the official Helping-Hand website's URL.

#### Note on iOS devices

Apple has strict rules when it comes to iOS browser, and notably that they must all use the WebKit engine.
Unfortunately, to this day Apple still does not support the LNA browser feature for the WebKit engine, meaning any mixed-content request even when made on local network devices that correctly implement the preflight headers won't be allowed.

That unfortunately forces the use of the HTTPs protocol to communicate locally to the microcontrollers for iOS devices, at least until Apple decides to implement the LNA feature.
This is currently implemented in the project by having an HTTPs server running on the microcontroller, alongside the regular HTTP server with a common logic handling process.
The microcontrollers are therefore using self-signed certificates for each device, created at compile time when flashing the chips.

Of course, the iOS browsers won't accept these self-signed certificate by default so they first need to be downloaded on the iOS device by using the `http://hh-0001.local/cert` address (replacing `hh-0001` by the ID of the target Helping-Hand device).
Then the user can follow the procedure explained in the `./docs/ios_cert.md` document to save and trust that certificate.

To finally gain access to the Helping-Hand device from the user interface, they'll have to enable the HTTPs mode from the settings menu.

**Limitations**

This method currently has 2 major limitations:

- The ESP32 C6 hardware can only support up to 3 simultaneous HTTPs connections.
- The policy of Apple regarding self-signed certificates is that they can only be valid for a maximum of 1 year before automatically expiring. Therefore it requires opening up the Helping-Hand device to reflash a new certificate once per year.

A real longer term solution would be to maintain and deploy a native iOS application (which isn't cheap), or that Apple eventually adds support for the LNA protocol to their web engine, or allow for other browser engines to be used on their mobile devices.
