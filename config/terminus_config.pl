:- module(config,[
              version/1,
              server/1,
              server_name/1,
              server_port/1,
              worker_amount/1,
              max_transaction_retries/1,
              index_template/1,
              default_database_path/1,
              jwt_public_key_path/1,
              jwt_public_key_id/1,
              registry_path/1,
              console_base_url/1,
              ssl_cert/1,
              ssl_cert_key/1,
              pack_dir/1,
              https_enabled/0,
              autologin_enabled/0,
              tmp_path/1,
              server_worker_options/1,
              http_options/1,
              max_journal_queue_length/1,
              ignore_ref_and_repo_schema/0
          ]).

:- use_module(core(util/utils)).

version('4.0.0').

server_protocol(Value) :-
    (   https_enabled
    ->  Value = https
    ;   Value = http).

server_name(Value) :-
    getenv_default('TERMINUSDB_SERVER_NAME', '127.0.0.1', Value).

server_port(Value) :-
    getenv_default_number('TERMINUSDB_SERVER_PORT', 6363, Value).

worker_amount(Value) :-
    getenv_default_number('TERMINUSDB_SERVER_WORKERS', 8, Value).

max_transaction_retries(Value) :-
    getenv_default_number('TERMINUSDB_SERVER_MAX_TRANSACTION_RETRIES', 3, Value).

:- dynamic index_template_/1.

index_template(Value) :-
    index_template_(Value),
    !.
index_template(Value) :-
    once(expand_file_search_path(config('index.tpl'), Template_Path)),
    open(Template_Path, read, Template_Stream),
    read_string(Template_Stream, _, Value),
    assertz(index_template_(Value)),
    close(Template_Stream).

default_database_path(Value) :-
    getenv_default('TERMINUSDB_SERVER_DB_PATH', './storage/db', Value).

jwt_public_key_path(Value) :-
    getenv_default('TERMINUSDB_SERVER_JWT_PUBLIC_KEY_PATH', '', Value).

jwt_public_key_id(Value) :-
    getenv_default('TERMINUSDB_SERVER_JWT_PUBLIC_KEY_ID', '', Value).

console_base_url(Value) :-
    getenv_default('TERMINUSDB_CONSOLE_BASE_URL', 'https://dcm.ist/console/v4.0.0', Value).

https_enabled :-
    getenv_default('TERMINUSDB_HTTPS_ENABLED', 'true', Value),
    Value = 'true'.

autologin_enabled :-
    getenv_default('TERMINUSDB_AUTOLOGIN_ENABLED', 'false', Value),
    Value = 'true'.

ssl_cert(Value) :-
    expand_file_search_path(terminus_home('localhost.crt'), Default),
    getenv_default('TERMINUSDB_SSL_CERT', Default, Value).

ssl_cert_key(Value) :-
    expand_file_search_path(terminus_home('localhost.key'), Default),
    getenv_default('TERMINUSDB_SSL_CERT_KEY', Default, Value).

pack_dir(Value) :-
    getenv('TERMINUSDB_SERVER_PACK_DIR', Value).

registry_path(Value) :-
    once(expand_file_search_path(plugins('registry.pl'), Path)),
    getenv_default('TERMINUSDB_SERVER_REGISTRY_PATH', Path, Value).

tmp_path(Value) :-
    user:file_search_path(terminus_home, Dir),
    atom_concat(Dir,'/tmp',TmpPathRelative),
    getenv_default('TERMINUSDB_SERVER_TMP_PATH', TmpPathRelative, Value).

server(Server) :-
    server_protocol(Protocol),
    server_name(Name),
    server_port(Port),
    atomic_list_concat([Protocol,'://',Name,':',Port],Server).

server_worker_options([]).

http_options([]).

% this number can never be less than 4 or bad things will happen.
max_journal_queue_length(30).

:- table ignore_ref_and_repo_schema/0.
ignore_ref_and_repo_schema :-
    getenv('TERMINUSDB_IGNORE_REF_AND_REPO_SCHEMA', true).

:- set_prolog_flag(stack_limit, 8_589_934_592).

% Turn off mavis
:- set_prolog_flag(optimise, true).
