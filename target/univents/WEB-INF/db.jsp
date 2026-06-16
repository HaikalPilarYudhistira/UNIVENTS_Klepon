<%@ page import="java.sql.*" %>
<%!
  // =============================================
  //  KONFIGURASI DATABASE - Sesuaikan dengan env
  // =============================================
static final String DB_URL    = "jdbc:mariadb://localhost:3306/univents";
static final String DB_USER   = "root";
static final String DB_PASS   = "";
static final String DB_DRIVER = "org.mariadb.jdbc.Driver";

  public static Connection getConnection() throws Exception {
    Class.forName(DB_DRIVER);
    return DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
  }
%>
