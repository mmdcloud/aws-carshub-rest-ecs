import Link from "next/link";
import { useParams, useRouter } from "next/navigation";

const OrderDetailsCard = ({ data }) => {
    const router = useRouter();
    const params = useParams();
    return (
        <div className="rounded-sm border border-stroke bg-white px-5 pb-2.5 pt-6 shadow-default dark:border-strokedark dark:bg-boxdark sm:px-7.5 xl:pb-1">
            <h4 className="mb-6 text-xl font-semibold text-black dark:text-white">
                Order Details
            </h4>

            <div className="flex flex-col">
                <div className="flex flex-row justify-between rounded-sm bg-gray-2 dark:bg-meta-4">
                    <div className="p-2.5 xl:p-5">
                        <h5 className="text-sm font-medium uppercase xsm:text-base">
                            Key
                        </h5>
                    </div>
                    <div className="p-2.5 text-center xl:p-5">
                        <h5 className="text-sm font-medium uppercase xsm:text-base">
                            Value
                        </h5>
                    </div>
                </div>

                <div className=" flex flex-row justify-between rounded-sm  dark:bg-meta-4 ">
                    <div className="p-2.5 xl:p-5">
                        <h5 className="text-sm font-medium  xsm:text-base">
                            Inventory Id
                        </h5>
                    </div>
                    <div className="p-2.5 text-center xl:p-5">
                        <h5 onClick={() => {
                            router.push("/inventory/" + data.inventoryId);
                        }} className="text-sm font-medium cursor-pointer text-blue-500 uppercase xsm:text-base">
                            #{data.inventoryId}
                        </h5>
                    </div>
                </div>

                <div className=" flex flex-row justify-between rounded-sm dark:bg-meta-4">
                    <div className="p-2.5 xl:p-5">
                        <h5 className="text-sm font-medium  xsm:text-base">
                            Buyer
                        </h5>
                    </div>
                    <div className="p-2.5 text-center xl:p-5">
                        <h5 className="text-sm font-medium uppercase xsm:text-base">
                            {data.buyer.fullname}
                        </h5>
                    </div>
                </div>

                <div className=" flex flex-row justify-between rounded-sm  dark:bg-meta-4">
                    <div className="p-2.5 xl:p-5">
                        <h5 className="text-sm font-medium  xsm:text-base">
                            Total Amount
                        </h5>
                    </div>
                    <div className="p-2.5 text-center xl:p-5">
                        <h5 className="text-sm font-medium uppercase xsm:text-base">
                            ₹ {data.totalAmount}
                        </h5>
                    </div>
                </div>

                <div className=" flex flex-row justify-between rounded-sm  dark:bg-meta-4">
                    <div className="p-2.5 xl:p-5">
                        <h5 className="text-sm font-medium  xsm:text-base">
                            Discount
                        </h5>
                    </div>
                    <div className="p-2.5 text-center xl:p-5">
                        <h5 className="text-sm font-medium uppercase xsm:text-base">
                            ₹ {data.discount}
                        </h5>
                    </div>
                </div>

                <div className=" flex flex-row justify-between rounded-sm  dark:bg-meta-4">
                    <div className="p-2.5 xl:p-5">
                        <h5 className="text-sm font-medium  xsm:text-base">
                            Date
                        </h5>
                    </div>
                    <div className="p-2.5 text-center xl:p-5">
                        <h5 className="text-sm font-medium uppercase xsm:text-base">
                            {data.date}
                        </h5>
                    </div>
                </div>

                <div className=" flex flex-row justify-between rounded-sm  dark:bg-meta-4">
                    <div className="p-2.5 xl:p-5">
                        <h5 className="text-sm font-medium  xsm:text-base">
                            Invoice
                        </h5>
                    </div>
                    <div className="p-2.5 text-center xl:p-5">
                        <Link target="_blank" href={"/orders/"+params.id+"/invoice"} className="text-sm font-medium cursor-pointer text-blue-500 xsm:text-base">
                            Generate
                        </Link>
                    </div>
                </div>
            </div>
        </div>
    );
};

export default OrderDetailsCard;
