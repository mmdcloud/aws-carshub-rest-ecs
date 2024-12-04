import { useParams, useRouter } from "next/navigation";
import { Splide, SplideSlide } from '@splidejs/react-splide';
import Image from "next/image";
const CarouselComponent = ({ data }) => {
    return (
        <div className="rounded-sm border border-stroke bg-white px-5 pb-2.5 pt-6 shadow-default dark:border-strokedark dark:bg-boxdark sm:px-7.5 xl:pb-1">
            <h4 className="mb-6 text-xl font-semibold text-black dark:text-white">
                Vehicle Images
            </h4>

            <div className="flex flex-col">
                <Splide aria-label="My Favorite Images">
                    {
                        data.length == 0 ? <Image
                            width={256}
                            height={256}
                            src={"/images/notfound.png"}
                            alt="notfound"
                            style={{
                                margin: "auto",
                                width: "auto",
                                height: "auto",
                            }}
                        /> : data.map((x, index) => {
                            return <SplideSlide key={index}>
                                <Image
                                    width={256}
                                    height={512}
                                    src={"https://"+process.env.CLOUDFRONT_DISTRIBUTION_URL + "/" + x.path}
                                    alt="User"
                                    style={{
                                        margin: 'auto',
                                        width: "auto",
                                        height: "512px",
                                    }}
                                />
                            </SplideSlide>
                        })
                    }
                </Splide>
            </div>
        </div>
    );
};

export default CarouselComponent;
