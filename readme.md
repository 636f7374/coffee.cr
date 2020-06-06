<div align = "center"><img src="images/icon.png" width="256" height="256" /></div>

<div align = "center">
  <h1>Coffee.cr - Cloudflare Edge Server Booster</h1>
</div>

<p align="center">
  <a href="https://crystal-lang.org">
    <img src="https://img.shields.io/badge/built%20with-crystal-000000.svg" /></a>
  <a href="https://github.com/636f7374/coffee.cr/actions">
    <img src="https://github.com/636f7374/coffee.cr/workflows/Continuous%20Integration/badge.svg" /></a>
  <a href="https://github.com/636f7374/coffee.cr/releases">
    <img src="https://img.shields.io/github/release/636f7374/coffee.cr.svg" /></a>
  <a href="https://github.com/636f7374/coffee.cr/blob/master/license">
    <img src="https://img.shields.io/github/license/636f7374/coffee.cr.svg"></a>
</p>

<div align = "center"><a href="#"><img src="images/terminal.png"></a></div>

## Description

* It is used to speed up the connection to Cloudflare Pop Edge Server
  * Compared to Cloudflare Argo Tunnel `2x - 4x faster`
* It can be used as Command Line or Crystal Shard
* It can filter the server of the country or region you specified
  * IATA (E.g. `TNR`)
  * Edge (E.g. `Antananarivo_Madagascar`)
  * Region (E.g. `Africa`)
* It is compatible with Crystal Durian.cr Domain Name System Resolver


## Why Use

* You want to connect to the Cloudflare Pop Edge Server in or near your home country.
  * For example, if you live in France, you want to connect to a server in France.
  * But because of your internet or AnyCast or free plan.
  * Leading to Cloudflare not choosing the best route for you.
  * You finally got LAX (Los Angeles), SJC (San Jose), AMS (Amsterdam) ...
  * You are frustrated, so you use this, It quickly matches the best route for you.
* It uses `CF-RAY` HTTP Header to determine the geographical location of the server.
  * LACP (Link Aggregation Control Protocol)
  * This usually improves Link aggregation speed.
* The results are time-sensitive and usually only last for a while.
  * So it will be suitable to use it as Crystal Shard.

## Fact

* We created it to increase the speed of our Chinese customers connecting to the "International" Internet.
  * After using it, Chinese users will connect to Cloudflare Pop Edge Server in Hong Kong, Singapore.
  * In bad network environment, speed up YouTube from 480P to 1080P. 

## Features

* [X] It can be perfectly combined with Crystal Domain Name System Resolver: [Durian.cr](https://github.com/636f7374/durian.cr).
* [X] It can be used as Command Line and Shard.
* [X] It can maximize the choice of geographic location IATA / Edge / Region.
* [X] It can increase the network speed of servers hosted on CLoudflare (Client).
* [X] Loosely coupled design, clean syntax, high performance.
* [ ] Command Line local turbo server.
* [X] It is thread-safe, which means you ca n’t go wrong when using multithreading.

## Tips

* Command Line
  * You can specify a different export location for each scan through the configuration file.
  * Or use ARGV to specify a single export location.

## Import and Export

* Import

```yaml
- ipRange: 198.41.214.0/23
  export: /Users/User/sample
  needles: asia
  excludes:
    needles: sin
    type: iata
  timeout:
    connect: 2
    read: 2
    write: 2
  type: region
- ipRange: 190.93.244.0/22
  export: /Users/User/sample
  needles: asia
  excludes:
    needles: sin
    type: iata
  timeout:
    connect: 2
    read: 2
    write: 2
  type: region
- ipRange: 172.64.160.0/20
  export: /Users/User/sample
  needles: asia
  excludes:
    needles: sin
    type: iata
  timeout:
    connect: 2
    read: 2
    write: 2
  type: region
- ipRange: 172.64.96.0/20
  export: /Users/User/sample
  needles: asia
  excludes:
    needles: sin
    type: iata
  timeout:
    connect: 2
    read: 2
    write: 2
  type: region
- ipRange: 162.159.132.0/24
  export: /Users/User/sample
  needles: asia
  excludes:
    needles: sin
    type: iata
  timeout:
    connect: 2
    read: 2
    write: 2
  type: region
- ipRange: 162.159.46.0/24
  export: /Users/User/sample
  needles: asia
  excludes:
    needles: sin
    type: iata
  timeout:
    connect: 2
    read: 2
    write: 2
  type: region
- ipRange: 162.159.36.0/24
  export: /Users/User/sample
  needles: asia
  excludes:
    needles: sin
    type: iata
  timeout:
    connect: 2
    read: 2
    write: 2
  type: region
- ipRange: 162.159.128.0/19
  export: /Users/User/sample
  needles: asia
  excludes:
    needles: sin
    type: iata
  timeout:
    connect: 2
    read: 2
    write: 2
  type: region
- ipRange: 141.101.120.0/22
  export: /Users/User/sample
  needles: asia
  excludes:
    needles: sin
    type: iata
  timeout:
    connect: 2
    read: 2
    write: 2
  type: region
- ipRange: 104.18.0.0/20
  export: /Users/User/sample
  needles: asia
  excludes:
    needles: sin
    type: iata
  timeout:
    connect: 2
    read: 2
    write: 2
  type: region
```

* Export

```text
{"ipAddress":"162.159.36.5","edge":"HongKong","iata":"HKG","createdAt":"2020-04-10T01:15:43.971333000Z","timing":"171.98ms"}
{"ipAddress":"162.159.36.17","edge":"HongKong","iata":"HKG","createdAt":"2020-04-10T01:15:54.726890000Z","timing":"165.72ms"}
{"ipAddress":"162.159.36.22","edge":"HongKong","iata":"HKG","createdAt":"2020-04-10T01:15:58.489802000Z","timing":"171.66ms"}
{"ipAddress":"162.159.36.31","edge":"HongKong","iata":"HKG","createdAt":"2020-04-10T01:16:07.036998000Z","timing":"173.44ms"}
{"ipAddress":"162.159.36.50","edge":"HongKong","iata":"HKG","createdAt":"2020-04-10T01:16:24.045118000Z","timing":"165.44ms"}
{"ipAddress":"162.159.36.51","edge":"HongKong","iata":"HKG","createdAt":"2020-04-10T01:16:24.207770000Z","timing":"162.49ms"}
{"ipAddress":"162.159.36.60","edge":"HongKong","iata":"HKG","createdAt":"2020-04-10T01:16:30.179999000Z","timing":"167.71ms"}
{"ipAddress":"162.159.36.84","edge":"HongKong","iata":"HKG","createdAt":"2020-04-10T01:16:48.974894000Z","timing":"474.01ms"}
{"ipAddress":"162.159.36.94","edge":"HongKong","iata":"HKG","createdAt":"2020-04-10T01:16:57.753831000Z","timing":"552.71ms"}
{"ipAddress":"162.159.36.105","edge":"HongKong","iata":"HKG","createdAt":"2020-04-10T01:17:12.610249000Z","timing":"510.71ms"}
{"ipAddress":"162.159.36.116","edge":"HongKong","iata":"HKG","createdAt":"2020-04-10T01:17:24.517550000Z","timing":"189.18ms"}
{"ipAddress":"162.159.36.123","edge":"HongKong","iata":"HKG","createdAt":"2020-04-10T01:17:30.561109000Z","timing":"487.24ms"}
{"ipAddress":"162.159.36.126","edge":"HongKong","iata":"HKG","createdAt":"2020-04-10T01:17:32.852852000Z","timing":"467.81ms"}
{"ipAddress":"162.159.36.130","edge":"HongKong","iata":"HKG","createdAt":"2020-04-10T01:17:34.701067000Z","timing":"163.06ms"}
{"ipAddress":"162.159.36.136","edge":"HongKong","iata":"HKG","createdAt":"2020-04-10T01:17:39.692680000Z","timing":"369.2ms"}
{"ipAddress":"162.159.36.169","edge":"HongKong","iata":"HKG","createdAt":"2020-04-10T01:18:05.020376000Z","timing":"178.66ms"}
{"ipAddress":"162.159.36.184","edge":"HongKong","iata":"HKG","createdAt":"2020-04-10T01:18:14.476441000Z","timing":"170.79ms"}
{"ipAddress":"162.159.36.208","edge":"HongKong","iata":"HKG","createdAt":"2020-04-10T01:18:30.982121000Z","timing":"481.95ms"}
{"ipAddress":"162.159.36.230","edge":"HongKong","iata":"HKG","createdAt":"2020-04-10T01:18:45.955359000Z","timing":"179.87ms"}
{"ipAddress":"162.159.36.234","edge":"HongKong","iata":"HKG","createdAt":"2020-04-10T01:18:49.161769000Z","timing":"176.81ms"}
{"ipAddress":"162.159.36.241","edge":"HongKong","iata":"HKG","createdAt":"2020-04-10T01:18:53.381347000Z","timing":"168.33ms"}
```

## Usage

* Simple Example

```crystal
require "coffee"

config = Coffee::Config.parse ARGV
abort if config.tasks.empty?

scanner = Coffee::Scanner.new config.tasks, commandLine: true
scanner.render_pipe = STDOUT

scanner.perform
```

### Used as Shard

Add this to your application's shard.yml:

```yaml
dependencies:
  coffee:
    github: 636f7374/coffee.cr
```

### Installation

```bash
$ git clone https://github.com/636f7374/coffee.cr.git
$ cd coffee.cr && make build && make install
```

## Development

```bash
$ make test
```

## Credit

* [\_Icon - Freepik/GraphicDesign](https://www.flaticon.com/packs/graphic-design-125)

## Contributors

|Name|Creator|Maintainer|Contributor|
|:---:|:---:|:---:|:---:|
|**[636f7374](https://github.com/636f7374)**|√|√||

## License

* MIT License
