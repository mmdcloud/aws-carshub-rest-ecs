"use client";
import { useQuery } from "@tanstack/react-query";
import axiosInstance from "../../network/axiosInstance";
import PageLoader from "../../components/common/Loader/pageLoader";
import DefaultLayout from "@/components/Layouts/DefaultLayout";
import TableTwo from "@/components/Tables/TableTwo";
import { useRouter } from "next/navigation";
import CustomAlert from "@/components/CustomAlert/Alert";
import { Pencil } from "lucide-react";

const renderActions = (item, key) => {
  const router = useRouter();
  return (
    <div key={key} className="flex items-center space-x-3.5">
        <button onClick={() => {
          var params = new URLSearchParams(item);
          router.push("/brands/form?" + params);
        }} className="hover:text-primary">
          <Pencil size={16}/>
        </button>                
      </div>
  );
};

const tableDataKeys = [
  {
    header: "Id",
    key: "id"
  },
  {
    header: "Name",
    key: "name"
  },
  {
    header: "Country of Origin",
    key: "countryOfOrigin"
  },
  {
    header: "Actions",
    component: renderActions
  }
];

const Brands = () => {
  const router = useRouter();
  const { data, error, isLoading, isError } = useQuery({
    queryKey: ["brands"],
    queryFn: () => {
      return axiosInstance.get("/brands");
    }
  })  
  return (
    <DefaultLayout>
      {
        isError ? <CustomAlert message={error.message} /> :  isLoading ? <PageLoader /> : <TableTwo isActionVisible={true} actionOnClick={() => {
          router.push("/brands/form");
        }} title={"Brands"} tableDataKeys={tableDataKeys} data={data.data} />
      }
    </DefaultLayout>
  )
};
export default Brands;