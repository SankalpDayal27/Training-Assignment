
import java.sql.*;

public class Statements {

    private static final String SQLurl = "XYZ";
    private static final String SQLusername = "ABC";
    private static final String SQLpassword = "DEF";

    //Prepared Statement to create appointment
    public static boolean createAppointment(
        String healthProblem, Timestamp dateAndTime, Timestamp reminder, int userId, int doctorId) {
        Connection con = null;
        String query = "INSERT INTO appointment (healthproblem, dateandtime, reminder, user_id, doctor_id) VALUES(?, ?, ?, ?, ?)";

        try {
            con = DriverManager.getConnection(SQLurl, SQLusername, SQLpassword);
            PreparedStatement statement = con.prepareStatement(query, Statement.RETURN_GENERATED_KEYS);

            statement.setString(1, healthProblem);
            statement.setTimestamp(2, dateAndTime);
            statement.setTimestamp(3, reminder);
            statement.setInt(4, userId);
            statement.setInt(5, doctorId);

            statement.executeUpdate();
            ResultSet primarykey = statement.getGeneratedKeys();

            if (primarykey.next()) {
                int appointmentId = primarykey.getInt(1);
                System.out.println("Created appointment with ID: " + appointmentId);
            }

            statement.close();
        } catch (SQLException ex) {
            ex.printStackTrace();
            return false;
        } finally {
            if (con != null) {
                try {
                    con.close();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
        }
        return true;
    }


    //Callable statement to invoke stored procedure
    public static boolean createAppointmentUsingProcedure(int userId, int doctorId, String healthProblem, Timestamp dateAndTime, Timestamp reminder) {
        Connection con = null;
        CallableStatement stmt = null;

        try {
            // Establish connection
            con = DriverManager.getConnection(SQLurl, SQLusername, SQLpassword);

            // Define the stored procedure call
            String query = "{CALL InsertAppointment(?, ?, ?, ?, ?)}"; // Stored procedure with 5 IN parameters

            // Prepare the callable statement
            stmt = con.prepareCall(query);

            // Set IN parameters
            stmt.setString(1, healthProblem);
            stmt.setTimestamp(2, dateAndTime);
            stmt.setTimestamp(3, reminder);
            stmt.setInt(4, userId);
            stmt.setInt(5, doctorId);
            stmt.executeUpdate();

            System.out.println("Appointment created successfully.");
            return true;
        } catch (SQLException ex) {
            ex.printStackTrace();
            return false;
        } finally {

            try {
                if (stmt != null) stmt.close();
                if (con != null) con.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    public static void main(String[] args) {
       
        createAppointmentUsingProcedure(3, 2, "Pneumonia", Timestamp.valueOf("2024-01-01 10:00:00"), Timestamp.valueOf("2024-01-01 09:30:00"));  // Callable Statement
    }
}
