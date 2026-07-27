# syntax=docker/dockerfile:1

# ---------- Stage 1: build frontend (Vite) ----------
FROM node:22-alpine AS build
WORKDIR /app

# API dilayani same-origin oleh Express, jadi frontend memakai path relatif /api.
ARG VITE_API_URL=/api
ENV VITE_API_URL=$VITE_API_URL

COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build

# ---------- Stage 2: runtime (Express + hasil build) ----------
FROM node:22-alpine AS runtime
WORKDIR /app
ENV NODE_ENV=production

# Hanya dependency produksi.
COPY package*.json ./
RUN npm ci --omit=dev && npm cache clean --force

# Kode server + hasil build frontend.
COPY server ./server
COPY --from=build /app/dist ./dist

# Direktori upload (di-mount sebagai volume persisten di produksi).
RUN mkdir -p uploads

EXPOSE 4000

# Healthcheck memakai endpoint /api/health yang sudah ada.
HEALTHCHECK --interval=30s --timeout=5s --start-period=40s --retries=3 \
  CMD node -e "fetch('http://127.0.0.1:'+(process.env.PORT||4000)+'/api/health').then(r=>process.exit(r.ok?0:1)).catch(()=>process.exit(1))"

CMD ["node", "server/index.js"]
