open Mirage

let hook =
  let doc = Key.Arg.info ~doc:"GitHub push hook." ["hook"] in
  Key.(create "hook" Arg.(opt string "hook" doc))

let remote =
  let doc = Key.Arg.info
      ~doc:"Remote repository url, use suffix #foo to specify a branch 'foo': \
            https://github.com/hannesm/unipi.git#gh-pages"
      ["remote"]
  in
  Key.(create "remote"
         Arg.(opt string "https://github.com/hannesm/unipi#gh-pages" doc))

let port =
  let doc = Key.Arg.info ~doc:"HTTP listen port." ["port"] in
  Key.(create "port" Arg.(opt int 80 doc))

let tls_port =
  let doc = Key.Arg.info ~doc:"Enable TLS on given port." ["tls"] in
  Key.(create "tls" Arg.(opt (some int) None doc))

let ssh_seed =
  let doc = Key.Arg.info ~doc:"Seed for ssh private key." ["ssh-seed"] in
  Key.(create "ssh_seed" Arg.(opt (some string) None doc))

let ssh_authenticator =
  let doc = Key.Arg.info ~doc:"SSH host key authenticator." ["ssh-authenticator"] in
  Key.(create "ssh_authenticator" Arg.(opt (some string) None doc))

let awa_pin = "git+https://github.com/hannesm/awa-ssh.git"
and git_pin = "git+https://github.com/hannesm/ocaml-git.git#awa-future"
and conduit_pin = "git+https://github.com/hannesm/ocaml-conduit.git#awa-future"

let packages = [
  package ~min:"2.0.0" "irmin";
  package ~min:"2.0.0" "irmin-mirage";
  package ~min:"2.0.0" "irmin-mirage-git";
  package "cohttp-mirage";
  package "tls-mirage";
  package "magic-mime";
  package "logs";
  package ~pin:awa_pin "awa";
  package ~pin:awa_pin "awa-mirage";
  package ~pin:conduit_pin "conduit";
  package ~pin:conduit_pin "conduit-lwt";
  package ~pin:conduit_pin "conduit-mirage";
  package ~pin:git_pin "git";
  package ~pin:git_pin "git-http";
  package ~pin:git_pin "git-mirage";
]

let stack = generic_stackv4 default_network

let () =
  let keys = Key.([
      abstract hook; abstract remote;
      abstract port; abstract tls_port;
      abstract ssh_seed; abstract ssh_authenticator;
    ])
  in
  register "unipi" [
    foreign
      ~keys
      ~packages
      "Unikernel.Main"
      (stackv4 @-> resolver @-> conduit @-> pclock @-> mclock @-> job)
    $ stack
    $ resolver_dns stack
    $ conduit_direct ~tls:true stack
    $ default_posix_clock
    $ default_monotonic_clock
  ]