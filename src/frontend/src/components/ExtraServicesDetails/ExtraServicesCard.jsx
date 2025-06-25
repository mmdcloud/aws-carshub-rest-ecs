import Image from "next/image";

const ExtraServicesDetails = ({ data }) => {
  return (
    <div className="col-span-12 rounded-sm border border-stroke bg-white py-6 shadow-default dark:border-strokedark dark:bg-boxdark xl:col-span-4">
      <h4 className="mb-6 px-7.5 text-xl font-semibold text-black dark:text-white">
        Extra Services Opted
      </h4>

      <div>
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
          /> :
            data.map((item, key) => (
              <div
                className="flex items-center gap-5 px-7.5 py-3 hover:bg-gray-3 dark:hover:bg-meta-4"
                key={key}
              >
                <div className="relative h-14 w-14 rounded-full">
                  <Image
                    width={56}
                    height={56}
                    src={"/images/user/user-01.png"}
                    alt="User"
                    style={{
                      width: "auto",
                      height: "auto",
                    }}
                  />
                </div>

                <div className="flex flex-1 items-center justify-between">
                  <div>
                    <h5 className="font-medium text-black dark:text-white">
                      {item.title}
                    </h5>
                    <p>
                      <span className="text-sm text-black dark:text-white">
                        ₹ {item.price}
                      </span>
                      <span className="text-xs line-through ml-2">₹ {item.price + item.discount} </span>
                    </p>
                  </div>
                </div>
              </div>
            ))}
      </div>
    </div>
  );
};

export default ExtraServicesDetails;