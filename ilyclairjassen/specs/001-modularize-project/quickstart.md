# Quickstart: Eternal Sanctuary (Modular)

## Setup

1. **Install Dependencies**:
   ```bash
   npm install
   ```

2. **Development**:
   ```bash
   npm run dev
   ```
   Open `http://localhost:5173` to see the sanctuary.

3. **Building for Production**:
   ```bash
   npm run build
   ```
   Deploy the resulting `dist/` folder to Netlify.

## Environment Variables
1. Create a `.env` file in the root based on `.env.example`:
```text
VITE_SUPABASE_URL=qozvdxgkvxfelixuuogb.supabase.co
VITE_SUPABASE_ANON_KEY=your_key_here
```
*Note: The `VITE_` prefix is required for Vite to expose these variables to your frontend code.*

## Building for Production
```bash
npm run build
```
This generates a `dist/` folder. For Netlify deployment, set the build command to `npm run build` and the publish directory to `dist`.
