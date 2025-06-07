# Was letzte Tür?

Ist sie auf? Ist sie zu?

## Usage

`was-letzte-tuer <PORT> <DATABASE-PATH>`

- `PORT`: port to run on. default: 8080
- `DATABASE-PATH`: path where the database should be created. default: `$pwd/database`

## Endpoints

### `/now`

- Get current door status
- Method: `GET`
- Returns: `open`, `closed` or `maybe` plain text

### `/update`

- Set current door status
- Method: `POST`
- Parameter
  - `status`: `open` or `closed`
- Example `/update?status=open`

### `/gc`

- Run garbage collection on past door states
- Method: `POST`
- Returns: a stupid message

## Alternative Namen

- DATW "Dümmste anzunehmende Tür Website"
- Is the Door closured?
