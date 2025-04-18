import Image from "next/image";
import getValueByKeyPath from "@/utils/utils";
import { useAnimate } from "motion/react";
import { useEffect } from "react";

const TableTwo = ({ title, tableDataKeys, data, actionOnClick, onRowClick, isActionVisible }) => {

  return (
    <div className="rounded-sm border border-stroke bg-white shadow-default dark:border-strokedark dark:bg-boxdark">
      <div className="px-4 py-6 md:px-6 xl:px-7.5 w-full flex flex-row justify-between">
        <h4 className="text-xl font-semibold text-black dark:text-white">
          {title}
        </h4>
        {isActionVisible && <button
          onClick={actionOnClick}
          className="flex justify-center rounded bg-primary px-6 py-2 font-medium text-gray hover:bg-opacity-90"
          type="button"
        >
          Add
        </button>}
      </div>

      <div className={`grid grid-cols-${tableDataKeys.length} border-t border-stroke px-4 py-4.5 dark:border-strokedark sm:grid-cols-${tableDataKeys.length} md:px-6 2xl:px-7.5`}>
        {
          tableDataKeys.map((x, key) => {
            return <div key={key} className="col-span-1 flex items-center">
              <p className="font-medium">{x["header"]}</p>
            </div>
          })
        }
      </div>

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
      /> : data.map((item, key) => (
        <div
          className={`grid grid-cols-${tableDataKeys.length} border-t border-stroke px-4 py-4.5 dark:border-strokedark sm:grid-cols-${tableDataKeys.length} md:px-6 2xl:px-7.5`}
          key={key}
        >
          {
            tableDataKeys.map((y, index) => {
              return y["header"] === "Actions" ? y["component"](item, index) : <div key={index} className="col-span-1 flex items-center">
                {
                  y["cell"] !== undefined ? y["cell"](item, y) : <p className="text-sm text-black dark:text-white">
                    {getValueByKeyPath(item, y["key"])}
                  </p>
                }
              </div>
            })
          }
        </div>
      ))}
    </div>
  );
};

export default TableTwo;
