from __future__ import unicode_literals

import argparse
import json
import sys
import traceback


def convert_to_shell(config_data):
    shell_config_strings = []
    for option_name in config_data:
        shell_config_strings.append("%s=%s" % (option_name, config_data[option_name]))

    return "\n".join(shell_config_strings)


SUPPORTED_FORMATS = {
    'shell': convert_to_shell
}


def main():
    parser = argparse.ArgumentParser(description='General purpose config converter',
                                     formatter_class=argparse.ArgumentDefaultsHelpFormatter)

    parser.add_argument("input", help="Input config file in JSON format")
    parser.add_argument("out", help="Output config file. Format specified by the file extension.")

    args = parser.parse_args()

    out_file_name = args.out.decode('utf-8')
    target_format = out_file_name.lower()[out_file_name.rfind('.') + 1:]
    if target_format not in SUPPORTED_FORMATS:
        raise ValueError('Unknown target format %s' % target_format)

    with open(args.out, mode='w') as out_file:
        with open(args.input) as input_file:
            config_data = json.load(input_file)
            out_file.write(SUPPORTED_FORMATS[target_format](config_data))


if __name__ == "__main__":
    try:
        main()
    except Exception, ex:
        traceback.print_exc(file=sys.stdout)
        exit(1)

    exit(0)
