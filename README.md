<a id="readme-top"></a>


[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]
[![YouTube Playlist][youtube-shield]][youtube-url]


<!-- HEADER -->
<br />
<div align="center">
  <h3 align="center">Zig Bytes</h3>

  <a href="https://github.com/purefns/zig-bytes">
    <img src="assets/mascot.png" alt="ZigIsGreat mascot" width="100" height="120">
  </a>

  <br />
  <p align="center">
    The companion project to my Zig Bytes series, available as a standalone set of runnable examples.
    <br />
    <br />
    <a href="https://github.com/purefns/zig-bytes/issues/new?template=bug_report.md">Report Bug</a>
    ·
    <a href="https://github.com/purefns/zig-bytes/issues/new?template=feature_request.md">Request Feature</a>
    <br />
    <br />
  </p>
</div>



<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li><a href="#compatibility">Compatibility</a></li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#clone-the-repo">Clone the repo</a></li>
        <li><a href="#install-zig">Install Zig</a></li>
        <li><a href="#usage">Usage</a></li>
      </ul>
    </li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>



<!-- COMPATIBILITY -->
## Compatibility

This project currently has support for the following systems:

<br />
<div align="center">
  <table>
    <tr>
      <th width="200px">OS</th>
      <th width="200px">Support level</th>
    </tr>
    <tr>
      <td>Linux</td>
      <td>Full</td>
    </tr>
    <tr>
      <td>Windows</td>
      <td>Untested</td>
    </tr>
    <tr>
      <td>FreeBSD</td>
      <td>Untested</td>
    </tr>
    <tr>
      <td>MacOS</td>
      <td>Untested</td>
    </tr>
  </table>
  <br />
  <sub>
    <b>Note:</b>
    This is the <code>main</code> branch, which means there are probably bugs and missing sections.
    <br />
    This repository as a whole is also currently unfinished, which will likely make these issues worse.
    <br />
    <b>Please keep these things in mind when reporting bugs or other issues.</b>
    <br />
    <br />
    A tagged release for Zig version <code>0.13.0</code> is currently being worked on.
  </sub>
</div>

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- GETTING STARTED -->
## Getting Started

### Clone the repo

Run the following commands to clone the repository and enter the project directory:

```bash
git clone https://github.com/purefns/zig-bytes
cd zig-bytes
```


### Install Zig

You will need to have the Zig compiler installed on your system.

<!-- RENOVATE -->
**The current requred version is `0.13.0`.**

You can install it via a number of different methods, with availability depending on your OS:

* Using a [pre-built binary](https://ziglang.org/download/)
    - This is the recommended option for most people. Make sure to download the correct option for your operating system
      and CPU architecture.
* Using [a package manager](https://github.com/ziglang/zig/wiki/Install-Zig-from-a-Package-Manager)
    - This can be fine if your distribution/package manager's repositories are up-to-date, but a majority of them are not.
      This is likely due to the fast development speed of Zig - if you have a compatible version available to install,
      please feel free to do so.

There is also a `flake.nix` available that includes a devshell set up with the necessary dependencies.
To use it, just run the following command in the project directory:

```bash
nix develop
```


### Usage

To get started with the first example just run `zig build`.

To run a specific example use the `-Dexample=[NAME]` flag, i.e. `zig build -Dexample=assignment`.

To see the full list of valid example names (in order by chapter) run `zig build --help`.

Below is a demo of the default example:

<div align="center">
  <img src="assets/demo.gif" alt="Example GIF" width="80%">
</div>

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- ROADMAP -->
## Roadmap

- [ ] Finish each chapter's examples ([#18](https://github.com/purefns/zig-bytes/issues/18))
- [ ] Finish adding OS support
    - [ ] Windows ([#2](https://github.com/purefns/zig-bytes/issues/2))
    - [ ] FreeBSD ([#3](https://github.com/purefns/zig-bytes/issues/3))
    - [ ] MacOS ([#4](https://github.com/purefns/zig-bytes/issues/4))

See the [open issues](https://github.com/purefns/zig-bytes/issues) for a full list of proposed features (and known issues).

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- CONTRIBUTING -->
## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".
Don't forget to give the project a star! Thanks again!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- LICENSE -->
## License

Distributed under the MIT License. See `LICENSE` for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- CONTACT -->
## Contact

James Adam - zigisgreat@proton.me

Project Link: [https://github.com/purefns/zig-bytes](https://github.com/purefns/zig-bytes)

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- ACKNOWLEDGMENTS -->
## Acknowledgments

❤️ [Ziglings](https://ziglings.org) for helping me figure out how to create a custom build step

❤️ [ZigHelp](https://zighelp.org/) for inspiration on the course layout

❤️ [Best README Template](https://github.com/othneildrew/Best-README-Template) for the amazing template


<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/purefns/zig-bytes.svg?style=for-the-badge
[contributors-url]: https://github.com/purefns/zig-bytes/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/purefns/zig-bytes.svg?style=for-the-badge
[forks-url]: https://github.com/purefns/zig-bytes/network/members
[stars-shield]: https://img.shields.io/github/stars/purefns/zig-bytes.svg?style=for-the-badge
[stars-url]: https://github.com/purefns/zig-bytes/stargazers
[issues-shield]: https://img.shields.io/github/issues/purefns/zig-bytes.svg?style=for-the-badge
[issues-url]: https://github.com/purefns/zig-bytes/issues
[license-shield]: https://img.shields.io/github/license/purefns/zig-bytes.svg?style=for-the-badge
[license-url]: https://github.com/purefns/zig-bytes/blob/master/LICENSE
[youtube-shield]: https://img.shields.io/badge/YouTube_Playlist-grey?style=for-the-badge&logo=youtube&logoColor=red
[youtube-url]: https://youtube.com/playlist?list=PLlpKL2PE4xV-YPcbtiqQoO_kAPEF0Iumf&si=KtC_M7V4BDWVSz1n

