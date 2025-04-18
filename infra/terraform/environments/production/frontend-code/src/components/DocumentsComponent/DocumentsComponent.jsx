import Link from "next/link";
import Image from "next/image";
import { FileText } from "lucide-react";

const DocumentsComponent = ({ data }) => {
  return (
    <div className="col-span-12 rounded-sm border border-stroke bg-white py-6 shadow-default dark:border-strokedark dark:bg-boxdark xl:col-span-4">
      <h4 className="mb-6 px-7.5 text-xl font-semibold text-black dark:text-white">
        Documents
      </h4>

      <div>
        {data.length == 0 ? <Image
        width={256}
        height={256}
        src={"/images/notfound.png"}
        alt="notfound"
        style={{
          margin: "auto",
          width: "auto",
          height: "auto",
        }}
      /> :data.map((item, index) => (
          <Link
            target="_blank"
            key={index}
            href={"https://"+process.env.CDN_URL+"/"+item.path}
            className="flex items-center gap-5 px-7.5 py-3 hover:bg-gray-3 dark:hover:bg-meta-4"
          >
            <div className="relative h-14 w-14 rounded-full">
            <FileText size={"56"} />
              {/* <Image
                width={56}
                height={56}
                src={"/images/user/user-01.png"}
                alt="User"
                style={{
                  width: "auto",
                  height: "auto",
                }}
              /> */}
            </div>

            <div className="flex flex-1 items-center justify-between">
              <div>
                <h5 className="font-medium text-black dark:text-white">
                  {item.path}
                </h5>
                {/* <p>
                  <span className="text-sm text-black dark:text-white">
                    sdnasndjasndjasd
                  </span>
                </p> */}
              </div>
            </div>
          </Link>
        ))}
      </div>
    </div>
  );
};

export default DocumentsComponent;
