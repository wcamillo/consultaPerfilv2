@IsTest
public class UserControllerTest {

    @TestSetup
    static void setupTestData() {
        // Cria um perfil para ser usado no teste
        Profile perfil = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User managerUser = [SELECT Id FROM User WHERE Username = 'integration@00d8z000002hq94uae.com' LIMIT 1]; // Substitua com o e-mail do gerente

        // Cria um usuário de teste
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Username = 'testuser@example.com' + System.currentTimeMillis(),
            Alias = 'testusr',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = perfil.Id,
            LanguageLocaleKey = 'en_US',
            ManagerId = managerUser.Id
        );
        insert testUser;

        // Associa um Permission Set ao usuário
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'FileConnect_PS' LIMIT 1];
        PermissionSetAssignment psa = new PermissionSetAssignment(
            AssigneeId = testUser.Id,
            PermissionSetId = ps.Id
        );
        insert psa;
    }

    @IsTest
    static void testGetUsersWithDetails() {
        // Executa o método de teste com um nome de usuário parcial
        Test.startTest();
        List<UserController.UserWrapper> results = UserController.getUsersWithDetails('Test');
        Test.stopTest();

        // Verifica se os resultados são os esperados
        System.assertNotEquals(0, results.size(), 'Deveria retornar pelo menos um usuário');
        UserController.UserWrapper userWrapper = results[0];
        System.assertEquals('Test User', userWrapper.Name, 'O nome do usuário deveria ser Test User');
        System.assertEquals('System Administrator', userWrapper.ProfileName, 'O nome do perfil deveria ser System Administrator');
        System.assertNotEquals(0, userWrapper.PermissionSets.size(), 'O usuário deveria ter pelo menos um Permission Set');
    }

    @IsTest
    static void testGetUsersWithDetailsNoResults() {
        // Testa a pesquisa com um nome de usuário que não deve retornar resultados
        Test.startTest();
        List<UserController.UserWrapper> results = UserController.getUsersWithDetails('NonExistentUser');
        Test.stopTest();

        // Verifica se nenhum resultado é retornado
        System.assertEquals(0, results.size(), 'Não deveria retornar nenhum usuário');
    }
}
