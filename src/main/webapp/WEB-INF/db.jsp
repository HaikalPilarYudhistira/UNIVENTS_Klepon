<%@ page import="java.sql.*" %>
<%!
  static final String DB_URL =
      "jdbc:mariadb://yamanote.proxy.rlwy.net:44958/railway";

  static final String DB_USER = "root";

  static final String DB_PASS = "olTcJGZUeBVIIuSfQjuAvzbzYoHMBwnk";

  static final String DB_DRIVER = "org.mariadb.jdbc.Driver";

  public static Connection getConnection() throws Exception {
      Class.forName(DB_DRIVER);
      return DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
  }
%>