import os

MODULES_DIR = os.path.join(os.path.dirname(__file__), '..', 'Modules')
OUTPUT_FILE = os.path.join(os.path.dirname(__file__), 'mono_tenant_template.sql')
OUTPUT_FILE_NP = os.path.join(os.path.dirname(__file__), 'mono_tenant_template_no_polymorphic.sql')

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

def aggregate_sql_files(sql_files, output_file):
    with open(output_file, 'w', encoding='utf-8') as outfile:
        for sql_file in sql_files:
            with open(sql_file, 'r', encoding='utf-8') as infile:
                outfile.write(f"-- START OF: {os.path.basename(sql_file)}\n")
                outfile.write(infile.read())
                outfile.write(f"\n-- END OF: {os.path.basename(sql_file)}\n\n")

def main():
    modules_dir = os.path.abspath(MODULES_DIR)
    output_file = os.path.abspath(OUTPUT_FILE)
    output_file_np = os.path.abspath(OUTPUT_FILE_NP)
    sql_files = get_sql_files_in_order(modules_dir)
    # Full version
    aggregate_sql_files(sql_files, output_file)
    print(f"Aggregated {len(sql_files)} files into {output_file}")
    # No-polymorphic version
    sql_files_no_poly = [f for f in sql_files if not is_polymorphic_file(os.path.basename(f))]
    aggregate_sql_files(sql_files_no_poly, output_file_np)
    print(f"Aggregated {len(sql_files_no_poly)} files into {output_file_np} (without polymorphic scripts)")

if __name__ == "__main__":
    main()
