import configparser
import sys

def get_db_name(config_file="/etc/odoo/odoo.conf"):
    config = configparser.ConfigParser()
    config.read(config_file)
    return config.get("options", "dbfilter", fallback="default")

if __name__ == "__main__":
    print(get_db_name())