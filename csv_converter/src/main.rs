use csv::{ReaderBuilder, WriterBuilder};
use std::error::Error;
use std::fs::File;

fn convert_to_csv_robust(input_path: &str, output_path: &str) -> Result<(), Box<dyn Error>> {
    let input_file = File::open(input_path)?;

    // Configure reader to parse semicolon-delimited files
    let mut reader = ReaderBuilder::new()
        .delimiter(b';')
        .has_headers(true)
        .from_reader(input_file);

    let output_file = File::create(output_path)?;

    // Configure writer to output standard comma-delimited files
    let mut writer = WriterBuilder::new()
        .delimiter(b',')
        .has_headers(true)
        .from_writer(output_file);

    // Read and write the header row
    if let Ok(headers) = reader.headers() {
        writer.write_record(headers)?;
    }

    // Read and write data records
    for result in reader.records() {
        let record = result?;
        writer.write_record(&record)?;
    }

    writer.flush()?;
    Ok(())
}

fn main() {
    let files = vec![
        ("EV_2026.A33", "EV_2026_A33.csv"),
        ("EV_2026.B33", "EV_2026_B33.csv"),
        ("EV_2026.C33", "EV_2026_C33.csv"),
    ];

    for (input, output) in files {
        match convert_to_csv_robust(input, output) {
            Ok(_) => println!("Successfully converted {} to {}", input, output),
            Err(e) => eprintln!("Failed to convert {}: {}", input, e),
        }
    }
}
