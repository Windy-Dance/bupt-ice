use bupt_api::constants::ALL_BUILDINGS;
use chrono::NaiveDate;

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    flutter_rust_bridge::setup_default_user_utils();
}

#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
pub struct BuildingDto {
    pub key: String,
    pub name: String,
    pub campus_name: String,
    pub campus_id: u32,
    pub default_floors: Vec<String>,
}

#[flutter_rust_bridge::frb(sync)]
pub fn get_sdk_version() -> String {
    format!("BUPT-API Rust SDK v{}", env!("CARGO_PKG_VERSION"))
}

#[flutter_rust_bridge::frb(sync)]
pub fn get_all_buildings() -> Vec<BuildingDto> {
    ALL_BUILDINGS
        .iter()
        .map(|b| BuildingDto {
            key: b.key.to_string(),
            name: b.partment_name.to_string(),
            campus_name: b.area.display_name().to_string(),
            campus_id: b.area.as_id(),
            default_floors: b.default_floors.iter().map(|f| f.to_string()).collect(),
        })
        .collect()
}

#[flutter_rust_bridge::frb(sync)]
pub fn calculate_week_number(term_start_date: Option<String>) -> Result<u32, String> {
    let anchor = match term_start_date {
        Some(ref d) => Some(
            NaiveDate::parse_from_str(d, "%Y-%m-%d")
                .map_err(|e| format!("Invalid term_start_date (expected YYYY-MM-DD): {e}"))?,
        ),
        None => None,
    };
    Ok(bupt_api::schedule::calculate_current_week(anchor))
}


