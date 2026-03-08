import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  output: "standalone",
  basePath: "/AURAMIKADAILY",
  assetPrefix: "/AURAMIKADAILY",
  images: {
    unoptimized: true,
  },
};

export default nextConfig;
