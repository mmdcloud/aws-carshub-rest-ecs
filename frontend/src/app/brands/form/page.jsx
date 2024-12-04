"use client";
import { useMutation } from "@tanstack/react-query";
import { useFormik } from "formik";
import axiosInstance from "../../../network/axiosInstance";
import toast from "react-hot-toast";
import DefaultLayout from "@/components/Layouts/DefaultLayout";
import { brandSchema } from "../../../utils/form-schemas";
import { useSearchParams } from "next/navigation";
import { useEffect } from "react";
import PageLoader from "@/components/common/Loader/pageLoader";

const BrandForm = () => {
  const params = useSearchParams();
  const formik = useFormik({
    initialValues: {
      id: '',
      name: '',
      countryOfOrigin: ''
    },
    onSubmit: (values) => {
      if (params.get("id") !== null) {
        updateMutation.mutate(values);
      }
      else {
        mutation.mutate(values);
      }
    },
    validationSchema: brandSchema
  });
  useEffect(() => {
    if (params.get("id") !== null) {
      formik.setFieldValue("id", params.get("id"));
      formik.setFieldValue("name", params.get("name"));
      formik.setFieldValue("countryOfOrigin", params.get("countryOfOrigin"));
    }
  }, []);
  const mutation = useMutation({
    mutationFn: (payload) => {
      return axiosInstance.post('/brands', payload);
    },
    onSuccess: (data, variables, context) => {
      if (data.status == 201) {
        formik.resetForm();
        toast.success("Created successfully !");
      }
    },
    onError: (error, variables, context) => {
      console.log(error);
      toast.error("Something went wrong !");
    }
  })
  const updateMutation = useMutation({
    mutationFn: (payload) => {
      return axiosInstance.patch('/brands/' + params.get("id"), payload);
    },
    onSuccess: (data, variables, context) => {
      formik.resetForm();
      toast.success("Updated successfully !");
    },
    onError: (error, variables, context) => {
      toast.error("Something went wrong !");
    }
  })
  return (
    <DefaultLayout>
      <div className="rounded-sm border border-stroke bg-white shadow-default dark:border-strokedark dark:bg-boxdark">
        <div className="border-b border-stroke px-6.5 py-4 dark:border-strokedark">
          <h3 className="font-medium text-black dark:text-white">
            Brand Form
          </h3>
        </div>
        <form onSubmit={formik.handleSubmit}>
          <div className="p-6.5">
            <div className="mb-4.5">
              <label className="mb-3 block text-sm font-medium text-black dark:text-white">
                Name
              </label>
              <input
                id="name"
                name="name"
                onChange={formik.handleChange}
                value={formik.values.name}
                type="text"
                placeholder="Name"
                className="w-full rounded border-[1.5px] border-stroke bg-transparent px-5 py-3 text-black outline-none transition focus:border-primary active:border-primary disabled:cursor-default disabled:bg-whiter dark:border-form-strokedark dark:bg-form-input dark:text-white dark:focus:border-primary"
              />
              {formik.errors.name && formik.touched.name ? (
                <div className="text-red mt-2">{formik.errors.name}</div>
              ) : null}
            </div>

            <div className="mb-5.5">
              <label className="mb-3 block text-sm font-medium text-black dark:text-white">
                Country Of Origin
              </label>
              <input
                id="countryOfOrigin"
                name="countryOfOrigin"
                onChange={formik.handleChange}
                value={formik.values.countryOfOrigin}
                type="text"
                placeholder="Country Of Origin"
                className="w-full rounded border-[1.5px] border-stroke bg-transparent px-5 py-3 text-black outline-none transition focus:border-primary active:border-primary disabled:cursor-default disabled:bg-whiter dark:border-form-strokedark dark:bg-form-input dark:text-white dark:focus:border-primary"
              />
              {formik.errors.countryOfOrigin && formik.touched.countryOfOrigin ? (
                <div className="text-red mt-2">{formik.errors.countryOfOrigin}</div>
              ) : null}
            </div>

            {
              updateMutation.isPending || mutation.isPending ? <PageLoader /> : <button type="submit" className="flex w-full justify-center rounded bg-primary p-3 font-medium text-gray hover:bg-opacity-90">
                Submit
              </button>
            }
          </div>
        </form>
      </div>
    </DefaultLayout>
  )
};
export default BrandForm;