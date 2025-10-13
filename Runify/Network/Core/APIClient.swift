// Centralize networking logic: Instead of scattering URLSession calls everywhere, APIClient handles them in one place.
// Responsibilities:
// - Uses URLSession to make GET, POST, PATCH, DELELTE calls
// - Converts Swift structs to JSON for APIs, Converts JSON responses into Swift models (Decodable).
// - Adds tokens, API keys, or other headers automatically.

import Foundation
