# Was letzte Tür?

Ist sie auf? Ist sie zu?

## Usage

`was-letzte-tuer <PORT> <DATABASE-PATH>`

`PORT`: port to run on. default: 8080
`DATABASE-PATH`: path where the database should be created. default: `$pwd/database`

## Endpoints

### `/now`

- Method: `GET`
- Returns: `open`, `closed` or `maybe` plain text

### `/update`

- Method: `POST`
- Parameter
    - `status`: `open` or `closed`

Example `/update?status=open`

### `/gc`

- Method: `POST`
- Returns: a stupid message

## Alternative Namen
- DATW "Dümmste anzunehmende Tür Website"
- Is the Door closured?
