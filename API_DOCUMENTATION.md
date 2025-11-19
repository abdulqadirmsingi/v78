# Street Football Rush - API Documentation

Complete REST API documentation for the Street Football Rush backend.

---

## Base URL

**Development**: `http://localhost:8080`

**Production**: Configure based on your deployment

---

## Authentication

Currently, the API does not require authentication. All endpoints are publicly accessible.

---

## Endpoints

### 1. Health Check

Check if the server is running and healthy.

**Endpoint**: `GET /health`

**Headers**: None required

**Response**: `200 OK`

```json
{
  "status": "ok",
  "timestamp": "2025-11-19T12:34:56Z"
}
```

**Example**:

```bash
curl http://localhost:8080/health
```

---

### 2. Submit Score

Submit a new player score to the leaderboard.

**Endpoint**: `POST /api/v1/score`

**Headers**:

- `Content-Type: application/json`

**Request Body**:

```json
{
  "name": "PlayerName",
  "score": 15
}
```

**Parameters**:
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| name | string | Yes | Player name (max 50 characters) |
| score | integer | Yes | Score value (must be >= 0) |

**Response**: `201 Created`

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "name": "PlayerName",
  "score": 15,
  "rank": 5,
  "created_at": "2025-11-19T12:34:56Z"
}
```

**Error Responses**:

`400 Bad Request` - Invalid input

```json
{
  "error": "player name cannot be empty"
}
```

```json
{
  "error": "score cannot be negative"
}
```

**Example**:

```bash
curl -X POST http://localhost:8080/api/v1/score \
  -H "Content-Type: application/json" \
  -d '{"name":"Alice","score":25}'
```

---

### 3. Get Leaderboard

Retrieve the top scores from the leaderboard.

**Endpoint**: `GET /api/v1/leaderboard`

**Headers**: None required

**Query Parameters**:
| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| limit | integer | No | 10 | Number of entries to return (max: 100) |

**Response**: `200 OK`

```json
{
  "leaderboard": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "name": "Alice",
      "score": 25,
      "rank": 1,
      "created_at": "2025-11-19T12:34:56Z"
    },
    {
      "id": "550e8400-e29b-41d4-a716-446655440001",
      "name": "Bob",
      "score": 20,
      "rank": 2,
      "created_at": "2025-11-19T12:35:00Z"
    }
  ],
  "total": 2
}
```

**Response Fields**:
| Field | Type | Description |
|-------|------|-------------|
| leaderboard | array | Array of score entries |
| total | integer | Total number of scores in database |

**Score Entry Fields**:
| Field | Type | Description |
|-------|------|-------------|
| id | string | Unique score ID (UUID) |
| name | string | Player name |
| score | integer | Score value |
| rank | integer | Player's rank (1 = highest) |
| created_at | string | ISO 8601 timestamp |

**Example**:

```bash
# Get top 10 scores
curl http://localhost:8080/api/v1/leaderboard

# Get top 50 scores
curl http://localhost:8080/api/v1/leaderboard?limit=50
```

---

### 4. Get Game Configuration

Retrieve game configuration parameters.

**Endpoint**: `GET /api/v1/config`

**Headers**: None required

**Response**: `200 OK`

```json
{
  "initial_defenders": 3,
  "defender_speed_base": 100.0,
  "defender_speed_increment": 10.0,
  "player_speed": 150.0,
  "field_width": 800,
  "field_height": 1200
}
```

**Response Fields**:
| Field | Type | Description |
|-------|------|-------------|
| initial_defenders | integer | Starting number of defenders |
| defender_speed_base | float | Base defender speed (pixels/second) |
| defender_speed_increment | float | Speed increase per goal |
| player_speed | float | Player movement speed |
| field_width | integer | Game field width in pixels |
| field_height | integer | Game field height in pixels |

**Example**:

```bash
curl http://localhost:8080/api/v1/config
```

---

## Error Handling

All errors follow a consistent format:

```json
{
  "error": "Error message description"
}
```

### HTTP Status Codes

| Code | Meaning               | Description                   |
| ---- | --------------------- | ----------------------------- |
| 200  | OK                    | Request successful            |
| 201  | Created               | Resource created successfully |
| 400  | Bad Request           | Invalid request parameters    |
| 404  | Not Found             | Endpoint not found            |
| 500  | Internal Server Error | Server error occurred         |

---

## Rate Limiting

Currently, there are no rate limits. In production, consider implementing rate limiting to prevent abuse.

**Recommended**:

- 100 requests per minute per IP for leaderboard
- 10 score submissions per minute per IP

---

## CORS

The API supports Cross-Origin Resource Sharing (CORS) for all origins by default.

**Configured Headers**:

- `Access-Control-Allow-Origin: *`
- `Access-Control-Allow-Methods: GET,POST,PUT,DELETE,OPTIONS`
- `Access-Control-Allow-Headers: Origin,Content-Type,Accept,Authorization`

To restrict origins in production, modify the `CORS_ORIGINS` environment variable.

---

## Data Models

### Score Model

```go
type Score struct {
    ID        string    `json:"id"`
    Name      string    `json:"name"`
    Score     int       `json:"score"`
    Rank      int       `json:"rank"`
    CreatedAt time.Time `json:"created_at"`
}
```

### Validation Rules

**Player Name**:

- Cannot be empty
- Maximum length: 50 characters
- Allowed characters: Any UTF-8

**Score**:

- Must be >= 0
- Must be an integer
- Maximum value: 2147483647 (int32 max)

---

## Integration Examples

### JavaScript/TypeScript

```javascript
// Submit Score
async function submitScore(name, score) {
  const response = await fetch("http://localhost:8080/api/v1/score", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ name, score }),
  });
  return await response.json();
}

// Get Leaderboard
async function getLeaderboard(limit = 10) {
  const response = await fetch(
    `http://localhost:8080/api/v1/leaderboard?limit=${limit}`
  );
  return await response.json();
}
```

### Python

```python
import requests

# Submit Score
def submit_score(name, score):
    url = "http://localhost:8080/api/v1/score"
    data = {"name": name, "score": score}
    response = requests.post(url, json=data)
    return response.json()

# Get Leaderboard
def get_leaderboard(limit=10):
    url = f"http://localhost:8080/api/v1/leaderboard?limit={limit}"
    response = requests.get(url)
    return response.json()
```

### Dart/Flutter

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

// Submit Score
Future<Map<String, dynamic>> submitScore(String name, int score) async {
  final response = await http.post(
    Uri.parse('http://localhost:8080/api/v1/score'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'name': name, 'score': score}),
  );
  return jsonDecode(response.body);
}

// Get Leaderboard
Future<Map<String, dynamic>> getLeaderboard({int limit = 10}) async {
  final response = await http.get(
    Uri.parse('http://localhost:8080/api/v1/leaderboard?limit=$limit'),
  );
  return jsonDecode(response.body);
}
```

### cURL Examples

```bash
# Health Check
curl http://localhost:8080/health

# Submit Score
curl -X POST http://localhost:8080/api/v1/score \
  -H "Content-Type: application/json" \
  -d '{"name":"TestPlayer","score":42}'

# Get Top 10 Leaderboard
curl http://localhost:8080/api/v1/leaderboard

# Get Top 25 Leaderboard
curl "http://localhost:8080/api/v1/leaderboard?limit=25"

# Get Game Config
curl http://localhost:8080/api/v1/config
```

---

## Testing the API

### Using Postman

1. Import the following collection:

**POST Submit Score**:

- URL: `http://localhost:8080/api/v1/score`
- Method: POST
- Headers: `Content-Type: application/json`
- Body (raw JSON):
  ```json
  {
    "name": "TestPlayer",
    "score": 10
  }
  ```

**GET Leaderboard**:

- URL: `http://localhost:8080/api/v1/leaderboard?limit=10`
- Method: GET

### Using HTTPie

```bash
# Health Check
http GET localhost:8080/health

# Submit Score
http POST localhost:8080/api/v1/score name="Player1" score:=25

# Get Leaderboard
http GET localhost:8080/api/v1/leaderboard limit==20
```

---

## Production Deployment

### Environment Variables

```env
PORT=8080
ENV=production
CORS_ORIGINS=https://yourdomain.com
LOG_LEVEL=info
```

### Security Recommendations

1. **Enable HTTPS**: Use TLS/SSL certificates
2. **Add Authentication**: Implement API keys or JWT tokens
3. **Rate Limiting**: Prevent abuse with request limits
4. **Input Validation**: Already implemented for name/score
5. **Database**: Upgrade from in-memory to PostgreSQL/MySQL
6. **Monitoring**: Add logging and metrics (Prometheus, Grafana)

### Scaling Considerations

- Use Redis for caching leaderboard
- Implement database connection pooling
- Deploy behind load balancer (nginx, HAProxy)
- Use CDN for static assets
- Implement pagination for large leaderboards

---

## Versioning

The API uses URL versioning: `/api/v1/`

Future breaking changes will use `/api/v2/` etc.

Current Version: **v1.0.0**

---

## Support

For issues or questions:

- Create an issue on GitHub
- Check backend logs: Server outputs to stdout
- Verify network connectivity between client and server

---

## Changelog

### Version 1.0.0 (2025-11-19)

- Initial release
- Health check endpoint
- Score submission
- Leaderboard retrieval
- Game configuration endpoint
- In-memory storage
- CORS support
