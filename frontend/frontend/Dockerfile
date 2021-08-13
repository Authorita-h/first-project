FROM node:latest AS builder
COPY . /frontend
WORKDIR /frontend
RUN yarn build

FROM nginx:alpine
COPY --from=builder /frontend/build /usr/share/nginx/html/
