#!/usr/bin/env bash
set -euo pipefail

umask 0002

: "${WORKSPACE:=/data/odoo}"
: "${ODOO_BRANCH:=18.0}"
: "${ODOO_REPO:=https://github.com/odoo/odoo.git}"
: "${ODOO_THEMES_REPO:=https://github.com/odoo/design-themes.git}"

mkdir -p /data/odoo/odoo /data/odoo/themes /data/odoo/eyssen /data/odoo/addons \
         /data/filestore /data/sessions /data/config /data/log/odoo /data/log/supervisor \
         /data/codeserver/data /data/codeserver/config /data/run

rm -f /data/run/supervisor.sock || true
chmod 0770 /data/run

if git -C /data/odoo/odoo rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git -C /data/odoo/odoo fetch --depth=1 origin "${ODOO_BRANCH}"
  git -C /data/odoo/odoo checkout -B "${ODOO_BRANCH}" "origin/${ODOO_BRANCH}"
else
  rm -rf /data/odoo/odoo/* /data/odoo/odoo/.[!.]* /data/odoo/odoo/..?* 2>/dev/null || true
  git clone --depth 1 --branch "${ODOO_BRANCH}" "${ODOO_REPO}" "/data/odoo/odoo"
fi

if git -C /data/odoo/themes rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git -C /data/odoo/themes fetch --depth=1 origin "${ODOO_BRANCH}"
  git -C /data/odoo/themes checkout -B "${ODOO_BRANCH}" "origin/${ODOO_BRANCH}"
else
  rm -rf /data/odoo/themes/* /data/odoo/themes/.[!.]* /data/odoo/themes/..?* 2>/dev/null || true
  git clone --depth 1 --branch "${ODOO_BRANCH}" "${ODOO_THEMES_REPO}" "/data/odoo/themes"
fi

: "${DB_MAXCONN:=20}"
: "${LIMIT_MEMORY_SOFT:=20971520000}"
: "${LIMIT_MEMORY_HARD:=21508390912}"
: "${LIMIT_TIME_CPU:=60}"
: "${LIMIT_TIME_REAL:=120}"
: "${LIMIT_TIME_REAL_CRON:=120}"
: "${LOG_LEVEL:=info}"
: "${MAX_CRON_THREADS:=1}"
: "${WORKERS:=1}"
: "${XMLRPC_PORT:=8069}"
: "${LONGPOLLING_PORT:=8072}"
: "${XMLRPC_INTERFACE:=0.0.0.0}"

: "${ADMIN_PASSWORD:?ADMIN_PASSWORD required}"
: "${DB_HOST:?DB_HOST required}"
: "${DB_PORT:?DB_PORT required}"
: "${DB_REPLICA_HOST:=}"
: "${DB_REPLICA_PORT:=}"
: "${DB_USER:?DB_USER required}"
: "${DB_PASSWORD:?DB_PASSWORD required}"
: "${DBFILTER:?DBFILTER required}"

REPL_HOST="${DB_REPLICA_HOST:-$DB_HOST}"
REPL_PORT="${DB_REPLICA_PORT:-$DB_PORT}"

if [ ! -f /data/config/odoo.conf ]; then
  cat > /data/config/odoo.conf <<EOF
[options]
addons_path = /data/odoo/odoo/addons,/data/odoo/themes,/data/odoo/eyssen,/data/odoo/eyssen/community_addons,/data/odoo/addons
data_dir = /data
admin_passwd = ${ADMIN_PASSWORD}
db_host = ${DB_HOST}
db_port = ${DB_PORT}
db_replica_host = ${REPL_HOST}
db_replica_port = ${REPL_PORT}
db_user = ${DB_USER}
db_maxconn = ${DB_MAXCONN}
db_password = ${DB_PASSWORD}
db_restore = True
dbfilter = ${DBFILTER}
limit_memory_soft = ${LIMIT_MEMORY_SOFT}
limit_memory_hard = ${LIMIT_MEMORY_HARD}
limit_time_cpu = ${LIMIT_TIME_CPU}
limit_time_real = ${LIMIT_TIME_REAL}
limit_time_real_cron = ${LIMIT_TIME_REAL_CRON}
log_level = ${LOG_LEVEL}
logfile = /data/log/odoo/odoo.log
xmlrpc_port = ${XMLRPC_PORT}
longpolling_port = ${LONGPOLLING_PORT}
max_cron_threads = ${MAX_CRON_THREADS}
proxy_mode = True
workers = ${WORKERS}
xmlrpc_interface = ${XMLRPC_INTERFACE}
EOF
fi

export HOME="${WORKSPACE}"
exec /usr/bin/supervisord -c /etc/supervisor/supervisord.conf
