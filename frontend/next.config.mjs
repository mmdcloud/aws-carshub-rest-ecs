/** @type {import('next').NextConfig} */
const nextConfig = {
    output: "standalone",
    env : {
        BASE_URL:process.env.BASE_URL,
        CLOUDFRONT_DISTRIBUTION_URL:process.env.CLOUDFRONT_DISTRIBUTION_URL
    },
    images: {
        remotePatterns: [
            {
                hostname: "picsum.photos",
                protocol: "https"
            },
            {
                hostname: process.env.CLOUDFRONT_DISTRIBUTION_URL,
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
