# syntax=docker/dockerfile:1

# ---------- Stage 1: build frontend (Vite) ----------
FROM node:22-alpine AS build
WORKDIR /app

# API dilayani same-origin oleh Express, jadi frontend memakai path relatif /api.
ARG VITE_API_URL=/api
ENV VITE_API_URL=$VITE_API_URL

# NODE_ENV=development memastikan devDependencies (tailwindcss, vite, postcss)
# tetap terpasang meski Coolify menyuntikkan NODE_ENV=production ke build.
ENV NODE_ENV=development

COPY package*.json ./
RUN npm ci --include=dev

COPY . .
RUN npm run build

# ---------- Stage 2: runtime (Express + hasil build) ----------
FROM node:22-alpine AS runtime
WORKDIR /app

# Default aman untuk container: bind ke semua interface, port 4000.
# Semua nilai ini bisa di-override lewat Environment Variables di Coolify.
ENV NODE_ENV=production \
    HOST=0.0.0.0 \
    PORT=4000

# Hanya dependency produksi.
COPY package*.json ./
RUN npm ci --omit=dev && npm cache clean --force

# Kode server + skema DB (untuk auto-migrate) + hasil build frontend.
COPY server ./server
COPY database ./database
COPY --from=build /app/dist ./dist

# Direktori upload (di-mount sebagai volume persisten di produksi).
RUN mkdir -p uploads

EXPOSE 4000

# Healthcheck memakai endpoint /api/health yang sudah ada.
HEALTHCHECK --interval=30s --timeout=5s --start-period=40s --retries=3 \
  CMD node -e "fetch('http://127.0.0.1:'+(process.env.PORT||4000)+'/api/health').then(r=>process.exit(r.ok?0:1)).catch(()=>process.exit(1))"

CMD ["node", "server/index.js"]
