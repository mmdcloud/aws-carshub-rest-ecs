const InventoryDetailsCard = ({ title, keys, values }) => {
    return (
        <div className="rounded-sm border border-stroke bg-white px-5 pb-2.5 pt-6 shadow-default dark:border-strokedark dark:bg-boxdark sm:px-7.5 xl:pb-1">
            {/* <h4 className="mb-6 text-xl font-semibold text-black dark:text-white">
                {title}
            </h4> */}

            <div className="flex flex-col">
                <div className="flex flex-row justify-between rounded-sm bg-gray-2 dark:bg-meta-4">
                    <div className="p-2.5 xl:p-5">
                        <h5 className="text-sm font-medium  xsm:text-base">
                            Key
                        </h5>
                    </div>
                    <div className="p-2.5 xl:p-5">
                        <h5 className="text-sm font-medium  xsm:text-base">
                            Value
                        </h5>
                    </div>
                </div>
                {
                    keys.map((x, index) => {
                        return <div key={index} className="flex flex-row justify-between rounded-sm  dark:bg-meta-4">
                            <div className="p-2.5 xl:p-5">
                                <h5 className="text-sm font-medium  xsm:text-base">
                                    {x}
                                </h5>
                            </div>
                            <div className="p-2.5 text-center xl:p-5">
                                <h5 className="text-sm font-medium cursor-pointer text-blue-500 xsm:text-base">
                                    {values[index]}
                                </h5>
                            </div>
                        </div>
                    })
                }
            </div>
        </div>
    );
};

export default InventoryDetailsCard;
