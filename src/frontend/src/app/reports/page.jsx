"use client";
import PageLoader from "@/components/common/Loader/pageLoader";
import DefaultLayout from "@/components/Layouts/DefaultLayout";
import TableTwo from "@/components/Tables/TableTwo";
import axiosInstance from "@/network/axiosInstance";
import { useMutation } from "@tanstack/react-query";
import { useFormik } from "formik";
import { FileDown } from "lucide-react";
import { useRouter } from "next/navigation";
import toast from "react-hot-toast";
import getValueByKeyPath from "@/utils/utils";
import { reportSchema } from "@/utils/form-schemas";

const renderActions = (item, key) => {
  // const router = useRouter();
  return (
    <div key={key} className="flex items-center space-x-3.5">
      <button onClick={() => {
        // var params = new URLSearchParams(item);
        // router.push("/users/form?" + params);
      }} className="hover:text-primary">
        <FileDown size={16} />
      </button>
    </div>
  );
};

const renderOrderIdCell = (item, y) => {
  const router = useRouter();
  return <p onClick={() => {
    router.push("/orders/" + item.id);
  }} className="text-sm text-blue-600 text-bold cursor-pointer dark:text-white">
    #{getValueByKeyPath(item, y["key"])}
  </p>
}

const renderVehicleModelCell = (item, y) => {  
  return <p className="text-sm text-blue-600 text-bold cursor-pointer dark:text-white">
    {item.inventory.model.brand.name} {item.inventory.model.name}
  </p>
}

const renderInventoryIdCell = (item, y) => {
  const router = useRouter();
  return <p onClick={() => {
    router.push("/inventory/" + item.id);
  }} className="text-sm text-blue-600 text-bold cursor-pointer dark:text-white">
    #{getValueByKeyPath(item, y["key"])}
  </p>
}

const tableDataKeys = [
  {
    header: "Order Id",
    key: "id",
    cell: renderOrderIdCell
  },
  {
    header: "Inventory Id",
    key: "inventoryId",
    cell: renderInventoryIdCell
  },
  {
    header: "Date",
    key: "date"
  },
  {
    header: "Buyer",
    key: "buyer.fullname"
  },
  {
    header: "Model",
    key: "inventory.model.name",
    cell:renderVehicleModelCell
  },
  {
    header: "Price",
    key: "inventory.price"
  },
  {
    header: "Status",
    key: "inventory.status"
  }
];


const Reports = () => {
  const formik = useFormik({
    initialValues: {
      fromDate: "",
      toDate: ""
    },
    onSubmit: (values) => {
      console.log(values);
      mutation.mutate(values);
    },
    validationSchema: reportSchema
  })
  const mutation = useMutation({
    mutationFn: (payload) => {
      return axiosInstance.post('/orders/generateReport', payload);
    },
    onSuccess: (data, variables, context) => {
      console.log(data);
      toast.success("Report generated successfully !");
    },
    onError: (error, variables, context) => {
      console.log(error);
      toast.error("Something went wrong !");
    }
  })
  return (
    <DefaultLayout>
      <div className="p-6.5 bg-white">
        <div className="mb-4.5 ">
          <form className="flex flex-col gap-6 xl:flex-row" onSubmit={formik.handleSubmit}>
            <div className="w-full xl:w-1/2">
              <label className="mb-3 block text-sm font-medium text-black dark:text-white">
                From Date
              </label>
              <div className="relative">
                <input
                  id="fromDate"
                  name="fromDate"
                  onChange={formik.handleChange}
                  value={formik.values.fromDate}
                  type="date"
                  className="form-datepicker w-full rounded border-[1.5px] border-stroke bg-transparent px-5 py-3 font-normal outline-none transition focus:border-primary active:border-primary dark:border-form-strokedark dark:bg-form-input dark:focus:border-primary"
                  data-class="flatpickr-right"
                />
                {formik.errors.fromDate && formik.touched.fromDate ? (
                  <div className="text-red mt-2">{formik.errors.fromDate}</div>
                ) : null}
              </div>
            </div>

            <div className="w-full xl:w-1/2">
              <label className="mb-3 block text-sm font-medium text-black dark:text-white">
                To Date
              </label>
              <div className="relative">
                <input
                  id="toDate"
                  name="toDate"
                  onChange={formik.handleChange}
                  value={formik.values.toDate}
                  type="date"
                  className="form-datepicker w-full rounded border-[1.5px] border-stroke bg-transparent px-5 py-3 font-normal outline-none transition focus:border-primary active:border-primary dark:border-form-strokedark dark:bg-form-input dark:focus:border-primary"
                  data-class="flatpickr-right"
                />
                {formik.errors.toDate && formik.touched.toDate ? (
                  <div className="text-red mt-2">{formik.errors.toDate}</div>
                ) : null}
              </div>
            </div>
            <div className="w-full xl:w-1/3 flex items-end justify-center">
              {/* <label className="mb-3 block text-sm font-medium text-black dark:text-white">
              </label> */}
              {
                mutation.isPending ? <PageLoader /> : <button
                  className="flex justify-center rounded bg-primary px-5 py-3 font-medium text-gray hover:bg-opacity-90"
                  type="submit"
                >
                  Generate
                </button>
              }
            </div>
          </form>
        </div>
        {
          mutation.data && <TableTwo title={"Report"} isActionVisible={false} tableDataKeys={tableDataKeys} data={mutation.data.data} />
        }
      </div>
    </DefaultLayout>
  );
};

export default Reports;