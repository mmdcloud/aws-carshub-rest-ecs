/** @type {import('next').NextConfig} */
const nextConfig = {
    output: "standalone",
    env : {
        BASE_URL:process.env.BASE_URL,
        CDN_URL:process.env.CDN_URL
    },
    images: {
        remotePatterns: [
            {
                hostname: "picsum.photos",
                protocol: "https"
            },
            {
                hostname: process.env.CDN_URL,
                protocol: "https"
            }
        ]
    },
    redirects: () => {
        return [
            {
                source: '/',
                destination: '/auth/signin',
                permanent: true,
            }
        ]
    }
};

export default nextConfig;
