# 📦 Backend Setup

## ⚙️ 1. Configuration `.env`

Créer le fichier [`.env`](.env)

```env
DATABASE_URL="postgresql://cert_user:1234@localhost:5432/certdb?schema=public"
PORT=3000
```

## ⚙️ 2. Importation BD

```sql
CREATE USER cert_user WITH PASSWORD '1234';
CREATE DATABASE certdb OWNER cert_user;
psql -U cert_user -d certdb -f sql/certdb.sql
```

## ⚙️ 3. Configuration cors dans [`app.js`](src/app.js)

```javascript
app.use(
  cors({
    origin: "exp://IP_REPLACE:8081",
    credentials: true,
  }),
```
