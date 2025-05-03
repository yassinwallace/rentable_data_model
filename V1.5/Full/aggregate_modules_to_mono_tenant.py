import os
import re
import argparse

MODULES_DIR = os.path.join(os.path.dirname(__file__), '..', 'Modules', 'Sql')
DEFAULT_OUTPUT_FILE = os.path.join(os.path.dirname(__file__), 'mono_tenant_template.sql')
DEFAULT_OUTPUT_FILE_NP = os.path.join(os.path.dirname(__file__), 'mono_tenant_template_no_polymorphic.sql')

# List of substrings that identify polymorphic relationship scripts
POLYMORPHIC_KEYWORDS = [
    'polymorphic_validations',
    'item_polymorphic_validations',
    'booking_polymorphic_validations',
    'location_polymorphic_validations',
]

def get_sql_files_in_order(directory):
    files = [f for f in os.listdir(directory) if f.endswith('.sql')]
    files.sort()
    return [os.path.join(directory, f) for f in files]

def is_polymorphic_file(filename):
    return any(keyword in filename for keyword in POLYMORPHIC_KEYWORDS)

def extract_step_number(filename):
    # Accepts both XX_YY_... and XX_... (e.g., 03_cross_module_fk.sql)
    match = re.match(r'^(\d{2})_\d{2}_.*\.sql$', filename)
    if match:
        return int(match.group(1))
    match = re.match(r'^(\d{2})_.*\.sql$', filename)
    if match:
        return int(match.group(1))
    return None

def parse_steps_arg(steps_arg):
    steps = set()
    for part in steps_arg.split(','):
        if '-' in part:
            start, end = part.split('-')
            steps.update(range(int(start), int(end)+1))
        else:
            steps.add(int(part))
    return steps

def aggregate_sql_files(sql_files, output_file):
    with open(output_file, 'w', encoding='utf-8') as outfile:
        for sql_file in sql_files:
            with open(sql_file, 'r', encoding='utf-8') as infile:
                outfile.write(f"-- START OF: {os.path.basename(sql_file)}\n")
                outfile.write(infile.read())
                outfile.write(f"\n-- END OF: {os.path.basename(sql_file)}\n\n")

def main():
    parser = argparse.ArgumentParser(description='Aggregate module SQL files into a single template.')
    parser.add_argument('--steps', type=str, help="Comma-separated list or ranges of step numbers, e.g. '1-5,7,10'. If omitted, includes all steps.")
    parser.add_argument('--phase', type=str, help="Name of the phase subfolder in 'Phases' to output the file(s) to.")
    parser.add_argument('--no-polymorphic', action='store_true', help="Also generate a version without polymorphic scripts.")
    parser.add_argument('--skip-polymorphic', action='store_true', help="Skip polymorphic scripts in the main output file.")
    args = parser.parse_args()

    modules_dir = os.path.abspath(MODULES_DIR)
    sql_files = get_sql_files_in_order(modules_dir)

    # Step filtering
    if args.steps:
        wanted_steps = parse_steps_arg(args.steps)
        filtered_sql_files = []
        for f in sql_files:
            step = extract_step_number(os.path.basename(f))
            if step and step in wanted_steps:
                filtered_sql_files.append(f)
        sql_files = filtered_sql_files

    # Output directory logic
    output_dir = os.path.dirname(DEFAULT_OUTPUT_FILE)
    if args.phase:
        output_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'Phases', args.phase))
        os.makedirs(output_dir, exist_ok=True)
    output_file = os.path.join(output_dir, 'mono_tenant_template.sql')
    output_file_np = os.path.join(output_dir, 'mono_tenant_template_no_polymorphic.sql')

    # Main output: skip polymorphic scripts if requested
    main_sql_files = sql_files
    if args.skip_polymorphic:
        main_sql_files = [f for f in sql_files if not is_polymorphic_file(os.path.basename(f))]
    aggregate_sql_files(main_sql_files, output_file)
    print(f"Aggregated {len(main_sql_files)} files into {output_file}{' (without polymorphic scripts)' if args.skip_polymorphic else ''}")

    # No-polymorphic version (if requested)
    if args.no_polymorphic:
        sql_files_no_poly = [f for f in sql_files if not is_polymorphic_file(os.path.basename(f))]
        aggregate_sql_files(sql_files_no_poly, output_file_np)
        print(f"Aggregated {len(sql_files_no_poly)} files into {output_file_np} (without polymorphic scripts)")

if __name__ == "__main__":
    main()
