import axios from 'axios';

const axiosInstance = axios.create({
	// Configuration
	baseURL:  process.env.BASE_URL,
	// baseURL:"http://localhost:3002",
	timeout: 10000,
	headers: {
		Accept: 'application/json',
	},
});

axiosInstance.interceptors.request.use(config => {
	const authToken = localStorage.getItem('authToken');
	if (authToken) {
		config.headers.Authorization = `Bearer ${authToken}`;
	}
	return config;
});

axiosInstance.interceptors.response.use(config => {
	console.log(config);
	if(config.status == 401)
	{
		return window.history.replaceState(myHistory, "<name>", "/auth/signin");
		// return window.location.href = '/auth/signin';
	}
	return config;
});

export default axiosInstance;