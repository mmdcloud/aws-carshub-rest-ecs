export default function getValueByKeyPath (obj, path) {
    return path.split('.').reduce((acc, key) => {
      return acc && acc[key] ? acc[key] : undefined;
    }, obj);
  };